import 'dart:developer';

import 'package:chatting_app/utils/secureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BroadcastShowerScreen extends StatefulWidget {
  final Map<String, dynamic> broadcastRoomInfo;
  const BroadcastShowerScreen({
    super.key,
    required this.broadcastRoomInfo
  });

  @override
  State<BroadcastShowerScreen> createState() => _BroadcastLiveScreenState();
}

class _BroadcastLiveScreenState extends State<BroadcastShowerScreen> {
  final _localRenderer =RTCVideoRenderer();
  MediaStream? _localStream;
  final Map<String, RTCPeerConnection> _peerConnections = {};
  final Map<String, List<RTCIceCandidate>> _candidateQueue = {};
  late StompClient stompClient;
  final String socketUrlSockJS = dotenv.get("WS_ADDRESS");

  bool frontCamera = true;
  bool micEnabled = true;
  bool rendererInitialized = false;

  @override
  void initState() {
    super.initState();
    _permission();
    _initRenderer();
  }

  Future<void> _permission() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _initRenderer() async {
    await _localRenderer.initialize();
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': frontCamera ? 'user' : 'environment'}
    });
    _localRenderer.srcObject = _localStream;
    if (mounted) {
      setState(() {
        rendererInitialized = true;
      });
    }
    _connectSocket();
  }

  void _connectSocket() {
    stompClient = StompClient(
      config: StompConfig(
        url: "$socketUrlSockJS/signaling",
        onConnect: (frame) => _onConnect(stompClient),
        onWebSocketError: (dynamic err) => print("WebSocket error: $err")
      )
    );
    stompClient.activate();
  }

  void _onConnect(StompClient client) {
    final roomId = widget.broadcastRoomInfo['roomId'];

    client.subscribe(
      destination: "/topic/broadcast/peer/offer/$roomId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        final offerSdp = data['sdp'];
        final viewerId = data['viewerId'];

        final pc = await _createPeerConnection(viewerId, roomId);
        _peerConnections[viewerId] = pc;

        await pc.setRemoteDescription(RTCSessionDescription(offerSdp, 'offer'));
        _localStream?.getTracks().forEach((track) => pc.addTrack(track, _localStream!));

        final answer = await pc.createAnswer();
        await pc.setLocalDescription(answer);

        client.send(
          destination: "/app/broadcast/peer/answer/$roomId/$viewerId",
          body: jsonEncode({'sdp': answer.sdp})
        );

        if (_candidateQueue.containsKey(viewerId)) {
          for (var candidate in _candidateQueue[viewerId]!) {
            pc.addCandidate(candidate);
          }
          _candidateQueue.remove(viewerId);
        }
      }
    );

    client.subscribe(
      destination: "/topic/broadcast/peer/candidate/$roomId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        final viewerId = data['viewerId'];

        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex']
        );

        final pc = _peerConnections[viewerId];
        if (pc != null && pc.getRemoteDescription != null) {
          await pc.addCandidate(candidate);
        } else {
          _candidateQueue.putIfAbsent(viewerId, () => []).add(candidate);
        }
      }
    );
  }

  Future<RTCPeerConnection> _createPeerConnection(String viewerId, String roomId) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };
    final pc = await createPeerConnection(config);

    pc.onIceCandidate = (candidate) {
      stompClient.send(
        destination: "/app/broadcast/peer/candidate/viewer/$roomId",
        body: jsonEncode({
          'viewerId': viewerId,
          'candidate': candidate.candidate,
          'sdpMid': candidate.sdpMid,
          'sdpMLineIndex': candidate.sdpMLineIndex
        })
      );
    };

    return pc;
  }

  Future<void> _switchCamera() async {
    final videoTrack = _localStream?.getVideoTracks().first;
    if (videoTrack != null) {
      await Helper.switchCamera(videoTrack);
      setState(() {
        frontCamera = !frontCamera;
      });
    }
  }

  void _toggleMic() {
    final audioTrack = _localStream?.getAudioTracks().first;
    if (audioTrack != null) {
      final enabled = audioTrack.enabled;
      audioTrack.enabled = !enabled;
      setState(() {
        micEnabled = !enabled;
      });
    }
  }

  void _endBroadcast() {
    for (final viewer in _peerConnections.keys) {
      stompClient.send(
        destination: "/app/broadcast/end/${widget.broadcastRoomInfo["roomId"]}",
        headers: {},
        body: 'end'
      );
    }
    Navigator.pop(context);
  }

  Future<void> _deleteBroadcastRoom() async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/broadcast?roomId=${widget.broadcastRoomInfo["roomId"]}");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.delete(
        apiAddress,
        headers: headers,
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        log("delete broadcast room: ${response.body}");

        _endBroadcast();
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 방송 삭제를 실패했습니다."))
        );
      }
    } catch (e) {
      // 예외 처리
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );
    }
  }

  @override
  void dispose() {
    _localRenderer.srcObject = null;
    _localRenderer.dispose();
    _localStream?.dispose();
    for (var pc in _peerConnections.values) {
      pc.close();
    }
    stompClient.deactivate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _deleteBroadcastRoom();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.broadcastRoomInfo["roomName"]),
        ),
        body: Column(
          children: [
            rendererInitialized
            ? Expanded(
                child: RTCVideoView(
                  _localRenderer,
                  mirror: true,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              )
            : const Center(
              child: CircularProgressIndicator()
            ),
            Row(
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
                )
              ]
            )
          ],
        ),
      ),
    );
  }
}