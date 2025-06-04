import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:uuid/uuid.dart';

class BroadcastViewerScreen extends StatefulWidget {
  final Map<String, dynamic> broadcastRoomInfo;
  const BroadcastViewerScreen({
    super.key,
    required this.broadcastRoomInfo
  });

  @override
  State<BroadcastViewerScreen> createState() => _BroadcastViewerScreenState();
}

class _BroadcastViewerScreenState extends State<BroadcastViewerScreen> {

  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  final List<RTCIceCandidate> _candidateQueue = [];
  late StompClient stompClient;
  final String viewerId = const Uuid().v4();
  final String socketUrlSockJS = dotenv.get("WS_ADDRESS");

  @override
  void initState() {
    super.initState();
    _initViewer();
  }

  Future<void> _initViewer() async {
    await _remoteRenderer.initialize();
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

  void _onConnect(StompClient client) async {
    final roomId = widget.broadcastRoomInfo['roomId'];
    _peerConnection = await _createPeerConnection(roomId);

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    client.send(
      destination: "/app/broadcast/peer/offer/$roomId",
      body: jsonEncode({
        'sdp': offer.sdp,
        'viewerId': viewerId
      })
    );

    client.subscribe(
      destination: "/topic/broadcast/peer/answer/$roomId/$viewerId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        final sdp = data['sdp'];

        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(sdp, 'answer')
        );

        for (var c in _candidateQueue) {
          await _peerConnection!.addCandidate(c);
        }
        _candidateQueue.clear();
      }
    );

    client.subscribe(
      destination: "/topic/broadcast/peer/candidate/viewer/$roomId",
      callback: (frame) async {
        final data = jsonDecode(frame.body!);
        final candidate = RTCIceCandidate(
          data['candidate'],
          data['sdpMid'],
          data['sdpMLineIndex']
        );

        if (_peerConnection?.getRemoteDescription() != null) {
          await _peerConnection!.addCandidate(candidate);
        } else {
          _candidateQueue.add(candidate);
        }
      }
    );
  }

  Future<RTCPeerConnection> _createPeerConnection(String roomId) async {
    final config = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };
    final pc = await createPeerConnection(config);
    pc.onTrack = (event) {
      if (event.track.kind == 'video') {
        setState(() {
          _remoteRenderer.srcObject = event.streams[0];
        });
      }
    };

    pc.onIceCandidate = (candidate) {
      stompClient.send(
        destination: "/app/broadcast/peer/candidate/$roomId",
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

  @override
  void dispose() {
    _remoteRenderer.dispose();
    _peerConnection?.close();
    stompClient.deactivate();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("라이브 시청"),
      ),
      body: Center(
        child: RTCVideoView(_remoteRenderer),
      ),
    );
  }
}