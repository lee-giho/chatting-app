import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:uuid/uuid.dart';

class VideoCallScreen extends StatefulWidget {
  final String chatRoomId;
  const VideoCallScreen({super.key, required this.chatRoomId});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with SingleTickerProviderStateMixin {
  StompClient? stompClient;
  final String socketUrlSockJS = dotenv.get("WS_ADDRESS");
  final String _myKey = const Uuid().v4();
  late String _roomId;

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  MediaStream? localStream;

  bool micEnabled = true;
  bool frontCamera = true;

  double _popUpVideoOriginalWidth = 640;
  double _popUpVideoOriginalHeight = 480;

  Offset _popUpVideoOffset = const Offset(0, 0); // 팝업 화면의 초기 위치

  final Map<String, RTCPeerConnection> pcListMap = {};
  final Map<String, List<RTCIceCandidate>> iceCandidateQueue = {};

  final config = {
    'iceServers': [
      {'url': "stun:stun.l.google.com:19302"}
    ],
    'sdpSemantics': 'unified-plan'
  };

  final sdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  late AnimationController _animationController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _roomId = widget.chatRoomId;
    initRenderers();
    permission();
    _enterScreen();

    _animationController =
        AnimationController(duration: Duration(milliseconds: 400), vsync: this);
    _flipAnimation =
        Tween<double>(begin: 1.0, end: -1.0).animate(_animationController);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _localRenderer.onResize = () {
      setState(() {
        _popUpVideoOriginalWidth = _localRenderer.videoWidth.toDouble();
        _popUpVideoOriginalHeight = _localRenderer.videoHeight.toDouble();
      });
    };
  }

  void permission() async {
    await [Permission.camera, Permission.microphone].request();
  }

  void _enterScreen() async {
    await startCam();

    stompClient = StompClient(
      config: StompConfig(
        url: "$socketUrlSockJS/signaling",
        onConnect: onConnect,
        onWebSocketError: (dynamic err) => print("WebSocket error: $err"),
      ),
    );
    stompClient!.activate();
    setState(() {});
  }

  void onConnect(StompFrame frame) {
    stompClient?.subscribe(
      destination: '/topic/call/key',
      callback: (_) {
        stompClient?.send(
            destination: '/app/send/key',
            headers: {},
            body: '"$_myKey"');
      },
    );

    stompClient?.subscribe(
      destination: '/topic/send/key',
      callback: (frame) async {
        String key = frame.body!.replaceAll('"', '');
        if (key == _myKey) return;
        if (!pcListMap.containsKey(key)) {
          final pc = await createPeer(key);
          if (_myKey.compareTo(key) < 0) {
            sendOffer(pc, key);
          }
        }
      },
    );

    stompClient?.subscribe(
      destination: '/topic/peer/offer/$_myKey/$_roomId',
      callback: (frame) async {
        final result = jsonDecode(frame.body!);
        final key = result['key'];
        final body = result['body'];
        final sdp = body['sdp'].replaceAll('setup:actpass', 'setup:active');
        final type = body['type'];

        final pc = await createPeer(key);
        await pc.setRemoteDescription(RTCSessionDescription(sdp, type));
        final answer = await pc.createAnswer();
        await pc.setLocalDescription(answer);

        stompClient?.send(
          destination: '/app/peer/answer/$key/$_roomId',
          headers: {},
          body: jsonEncode({'key': _myKey, 'body': answer.toMap()}),
        );

        _flushIceCandidateQueue(key);
      },
    );

    stompClient?.subscribe(
      destination: '/topic/peer/answer/$_myKey/$_roomId',
      callback: (frame) async {
        final result = jsonDecode(frame.body!);
        final key = result['key'];
        final body = result['body'];
        final sdp = body['sdp'];
        final type = body['type'];

        final pc = pcListMap[key];
        if (pc != null) {
          await pc.setRemoteDescription(RTCSessionDescription(sdp, type));
          _flushIceCandidateQueue(key);
        }
      },
    );

    stompClient?.subscribe(
      destination: '/topic/peer/iceCandidate/$_myKey/$_roomId',
      callback: (frame) async {
        final result = jsonDecode(frame.body!);
        final key = result['key'];
        if (key == _myKey) return;

        final body = result['body'];
        final candidate = RTCIceCandidate(
            body['candidate'], body['sdpMid'], body['sdpMLineIndex']);

        final pc = pcListMap[key];
        if (pc == null) return;

        final remoteDesc = await pc.getRemoteDescription();
        if (remoteDesc == null) {
          iceCandidateQueue.putIfAbsent(key, () => []).add(candidate);
        } else {
          await pc.addCandidate(candidate);
        }
      },
    );

    stompClient?.subscribe(
      destination: '/topic/call/end/$_myKey/$_roomId',
      callback: (_) {
        Navigator.pop(context);
      },
    );
  }

  Future<void> startCam() async {
    final Map<String, dynamic> constraints = {
      'audio': true,
      'video': {
        'facingMode': frontCamera ? 'user' : 'environment',
      }
    };

    final stream = await navigator.mediaDevices.getUserMedia(constraints);
    localStream = stream;
    _localRenderer.srcObject = localStream;
    setState(() {});
  }

  Future<RTCPeerConnection> createPeer(String otherKey) async {
    final pc = await createPeerConnection(config, sdpConstraints);

    pc.onIceCandidate = (ice) {
      if (ice.candidate != null) {
        stompClient?.send(
          destination: '/app/peer/iceCandidate/$otherKey/$_roomId',
          headers: {},
          body: jsonEncode({'key': _myKey, 'body': ice.toMap()}),
        );
      }
    };

    pc.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    localStream?.getTracks().forEach((track) {
      pc.addTrack(track, localStream!);
    });

    pcListMap[otherKey] = pc;
    return pc;
  }

  Future<void> _handleButtonPress() async {
    stompClient?.send(
      destination: '/app/call/key',
      headers: {},
      body: '"$_myKey"',
    );
  }


  void sendOffer(RTCPeerConnection pc, String otherKey) async {
    final offer = await pc.createOffer();
    await pc.setLocalDescription(offer);
    stompClient?.send(
      destination: '/app/peer/offer/$otherKey/$_roomId',
      headers: {},
      body: jsonEncode({'key': _myKey, 'body': offer.toMap()}),
    );
  }

  void _flushIceCandidateQueue(String key) async {
    final pc = pcListMap[key];
    if (pc == null || !iceCandidateQueue.containsKey(key)) return;
    for (final candidate in iceCandidateQueue[key]!) {
      await pc.addCandidate(candidate);
    }
    iceCandidateQueue.remove(key);
  }

  void _toggleMic() {
    if (localStream != null) {
      final audioTrack = localStream!.getAudioTracks().firstOrNull;
      if (audioTrack != null) {
        audioTrack.enabled = !audioTrack.enabled;
        setState(() {
          micEnabled = audioTrack.enabled;
        });
      }
    }
  }

  void _switchCamera() async {
    _animationController.forward(from: 0);
    frontCamera = !frontCamera;
    await localStream?.dispose();
    await startCam();

    for (var pc in pcListMap.values) {
      final senders = await pc.getSenders();
      for (var sender in senders) {
        if (sender.track?.kind == 'video') {
          await sender.replaceTrack(localStream!.getVideoTracks().first);
        }
      }
    }
  }

  void _endCall() {
    // 모든 연결된 상대방에게 종료 메시지 전송
    for (final targetKey in pcListMap.keys) {
      stompClient?.send(
        destination: '/app/call/end/$targetKey/$_roomId',
        headers: {},
        body: 'end',
      );
    }
    Navigator.pop(context);
  }

  @override
  void dispose() {
    for (var pc in pcListMap.values) {
      pc.close();
    }
    pcListMap.clear();

    localStream?.getTracks().forEach((track) => track.stop());
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    stompClient?.deactivate();

    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("_remoteRenderer.renderVideoL: ${_remoteRenderer.renderVideo}");
    double _popUpVideoWidth = MediaQuery.of(context).size.width * 0.3;
    double _popUpVideoRatio = _popUpVideoOriginalWidth / _popUpVideoOriginalHeight;
    return WillPopScope(
      onWillPop: () async {
        _endCall();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("영상 통화")
        ),
        body: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              RTCVideoView( // 메인 화면
                _remoteRenderer.renderVideo
                  ? _remoteRenderer
                  : _localRenderer,
                mirror: frontCamera,
              ),
              if (_remoteRenderer.renderVideo)
                Positioned( // 팝업 화면
                  left: _popUpVideoOffset.dx,
                  top: _popUpVideoOffset.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      final screenSize = MediaQuery.of(context).size;
                      final safePadding = MediaQuery.of(context).padding;
                      final double popUpHeight = _popUpVideoWidth * _popUpVideoRatio;
            
                      final double maxX = screenSize.width - (_popUpVideoWidth);
                      final double maxY = screenSize.height - safePadding.top - popUpHeight;
                      
                      setState(() {
                        _popUpVideoOffset = Offset(
                          (_popUpVideoOffset.dx + details.delta.dx).clamp(0.0, maxX),
                          (_popUpVideoOffset.dy + details.delta.dy).clamp(0.0, maxY)  
                        );
                      });
                    },
                    child: Container(
                      width: _popUpVideoWidth,
                      height: _popUpVideoWidth * _popUpVideoRatio,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(width: 4)
                      ),
                      child: AspectRatio(
                        aspectRatio: _popUpVideoRatio,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: RTCVideoView(
                            _localRenderer,
                            mirror: frontCamera,
                            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                          ),
                        ),
                      ),
                    ),
                  )
                ),
              Positioned( // 하단 버튼
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        micEnabled 
                          ? Icons.mic
                          : Icons.mic_off,
                        size: 40,
                      ),
                      onPressed: _toggleMic,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.cameraswitch,
                        size: 40,
                      ),
                      onPressed: _switchCamera,
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.call_end,
                        size: 40,
                        color: _remoteRenderer.renderVideo
                          ? Colors.red
                          : Colors.green
                      ),
                      onPressed: _remoteRenderer.renderVideo
                        ? _endCall
                        : _handleButtonPress
                    ),
                  ],
                )
              )            
            ],
          ),
        )
      ),
    );
  }
}
