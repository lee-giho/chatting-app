import 'package:flutter/material.dart';

class ChatRoomListScreen extends StatefulWidget {
  const ChatRoomListScreen({super.key});

  @override
  State<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: const Text(
            "채팅방 리스트"
          ),
        )
      ),
    );
  }
}