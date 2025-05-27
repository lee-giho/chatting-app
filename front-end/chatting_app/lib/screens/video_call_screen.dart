import 'dart:convert';
import 'package:flutter/material.dart';
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

class _VideoCallScreenState extends State<VideoCallScreen> {
  StompClient? stompClient;
  final String socketUrlSockJS = dotenv.get("WS_ADDRESS");
  final String _myKey = const Uuid().v4();
  late String _roomId;

  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  late MediaStream localStream;

  final Map<String, RTCPeerConnection> pcListMap = {};
  final Map<String, List<RTCIceCandidate>> iceCandidateQueue = {};

  final Map<String, dynamic> config = {
    'iceServers': [
      {'url': "stun:stun.l.google.com:19302"}
    ],
    'sdpSemantics': 'unified-plan'
  };

  final Map<String, dynamic> sdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true
    },
    'optional': []
  };

  @override
  void initState() {
    super.initState();
    _roomId = widget.chatRoomId;
    initRenderers();
    permission();
    _enterScreen();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    setState(() {});
  }

  void permission() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _handleButtonPress() async {
    stompClient?.send(
      destination: '/app/call/key',
      headers: {},
      body: '"$_myKey"'
    );
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
          body: '"$_myKey"'
        );
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
          body['candidate'],
          body['sdpMid'],
          body['sdpMLineIndex'],
        );

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
  }

  Future<void> startCam() async {
    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

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

    localStream.getTracks().forEach((track) {
      pc.addTrack(track, localStream);
    });

    pcListMap[otherKey] = pc;
    return pc;
  }

  void _flushIceCandidateQueue(String key) async {
    final pc = pcListMap[key];
    if (pc == null || !iceCandidateQueue.containsKey(key)) return;

    for (final candidate in iceCandidateQueue[key]!) {
      await pc.addCandidate(candidate);
    }

    iceCandidateQueue.remove(key);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Call")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: stompClient?.isActive == true ? _handleButtonPress : null,
            child: Text("Stream"),
          ),
          SizedBox(height: 16),
          Text("My Video"),
          SizedBox(width: 120, height: 120, child: RTCVideoView(_localRenderer, mirror: true)),
          SizedBox(height: 16),
          Text("Remote Video"),
          SizedBox(width: 120, height: 120, child: RTCVideoView(_remoteRenderer)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 1. 모든 PeerConnection 종료
    for (var pc in pcListMap.values) {
      pc.close();
    }
    pcListMap.clear();

    // 2. localStream 해제
    localStream.getTracks().forEach((track) => track.stop());
    _localRenderer.srcObject = null;
    _remoteRenderer.srcObject = null;

    // 3. WebSocket 종료
    stompClient?.deactivate();

    // 4. Renderer 해제
    _localRenderer.dispose();
    _remoteRenderer.dispose();

    super.dispose();
  }
}
