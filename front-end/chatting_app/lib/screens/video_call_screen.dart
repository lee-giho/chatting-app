import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class VideoCallScreen extends StatefulWidget {
  final String roomId;

  const VideoCallScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  RTCPeerConnection? _peerConnection;
  late StompClient _stompClient;

  final List<RTCIceCandidate> _pendingCandidates = [];
  bool _remoteDescriptionSet = false;

  bool get isInitiator => widget.roomId.codeUnitAt(0) % 2 == 0;

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
    _connectSocket();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    _stompClient.deactivate();
    super.dispose();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    setState(() {});
  }

  void _connectSocket() {
    final wsAddress = dotenv.get("API_ADDRESS");

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: "$wsAddress/ws-chat",
        onConnect: _onConnected,
        onWebSocketError: (error) => print('❌ WebSocket error: $error'),
      ),
    );

    _stompClient.activate();
  }

  void _onConnected(StompFrame frame) {
    print("✅ WebSocket connected");
    _createLocalStream();

    _stompClient.subscribe(
      destination: '/topic/offer',
      callback: (frame) async {
        print("📥 Received offer: ${frame.body}");
        if (_peerConnection?.signalingState ==
            RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
          print("❗️ 이미 local offer 상태, 상대 offer 무시");
          return;
        }

        final data = json.decode(frame.body!);
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']),
        );
        _remoteDescriptionSet = true;

        for (final candidate in _pendingCandidates) {
          await _peerConnection?.addCandidate(candidate);
        }
        _pendingCandidates.clear();

        _createAnswer();
      },
    );

    _stompClient.subscribe(
      destination: '/topic/answer',
      callback: (frame) async {
        print("📥 Received answer: ${frame.body}");
        final data = json.decode(frame.body!);
        await _peerConnection?.setRemoteDescription(
          RTCSessionDescription(data['sdp'], data['type']),
        );
        _remoteDescriptionSet = true;

        for (final candidate in _pendingCandidates) {
          await _peerConnection?.addCandidate(candidate);
        }
        _pendingCandidates.clear();
      },
    );

    _stompClient.subscribe(
      destination: '/topic/ice',
      callback: (frame) async {
        print("📥 Received ICE: ${frame.body}");
        final data = json.decode(frame.body!);
        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex'],
        );

        if (_remoteDescriptionSet) {
          await _peerConnection?.addCandidate(candidate);
        } else {
          _pendingCandidates.add(candidate);
        }
      },
    );
  }

  Future<void> _createLocalStream() async {
    var cameraStatus = await Permission.camera.request();
    var micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      final mediaConstraints = {
        'audio': true,
        'video': {
          'facingMode': 'user',
          'mandatory': {
            'minWidth': '640',
            'minHeight': '480',
          },
        },
      };

      MediaStream stream =
          await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localStream = stream;

      print('✅ Stream obtained. Video tracks: ${stream.getVideoTracks().length}');
      _localRenderer.srcObject = stream;
      setState(() {});

      await _createPeerConnection();

      if (isInitiator) {
        Future.delayed(const Duration(milliseconds: 300), _createOffer);
      }
    } else {
      print("❗️ 카메라/마이크 권한이 거부됨");
    }
  }

  Future<void> _createPeerConnection() async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    };

    _peerConnection = await createPeerConnection(config);

    _localStream?.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });

    _peerConnection!.onIceCandidate = (candidate) {
      print("📤 Sending ICE: ${candidate.toMap()}");
      _send('ice', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
        'room': widget.roomId,
      });
    };

    _peerConnection!.onTrack = (event) {
      print('📺 onTrack received. Remote stream tracks: ${event.streams[0].getTracks().length}');
      _remoteRenderer.srcObject = event.streams[0];
      setState(() {});
    };
  }

  void _createOffer() async {
    if (_peerConnection == null) return;

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    print("📤 Sending offer: ${offer.sdp}");
    _send('offer', {
      'type': offer.type,
      'sdp': offer.sdp,
      'room': widget.roomId,
    });
  }

  void _createAnswer() async {
    if (_peerConnection == null) return;

    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    print("📤 Sending answer: ${answer.sdp}");
    _send('answer', {
      'type': answer.type,
      'sdp': answer.sdp,
      'room': widget.roomId,
    });
  }

  void _send(String type, Map<String, dynamic> body) {
    print("📤 STOMP Send => /app/$type: $body");
    _stompClient.send(
      destination: '/app/$type',
      body: jsonEncode(body),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("영상통화"),
      ),
      body: _localRenderer.textureId != null
          ? Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: RTCVideoView(
                      _localRenderer,
                      mirror: true,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    color: Colors.grey[900],
                    child: RTCVideoView(
                      _remoteRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
