import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class BroadcastLiveScreen extends StatefulWidget {
  final Map<String, dynamic> broadcastRoomInfo;
  const BroadcastLiveScreen({
    super.key,
    required this.broadcastRoomInfo
  });

  @override
  State<BroadcastLiveScreen> createState() => _BroadcastLiveScreenState();
}

class _BroadcastLiveScreenState extends State<BroadcastLiveScreen> {
  final _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();

    _permission();
    _initCamera();    
  }

  @override
  void dispose() {
    super.dispose();
    _localRenderer.dispose();
  }

  void _permission() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _initCamera() async {
    await _localRenderer.initialize();

    final stream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': {'facingMode': 'user'}
    });

    _localRenderer.srcObject = stream;
  }

  void _endBroadcast() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.broadcastRoomInfo["roomName"]),
      ),
      body: Center(
        child: RTCVideoView(
          _localRenderer,
          mirror: true,
        ),
      ),
    );
  }
}