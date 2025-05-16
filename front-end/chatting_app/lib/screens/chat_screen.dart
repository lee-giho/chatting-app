import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  const ChatScreen({
    super.key,
    required this.chatRoomId
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
            children: [
              Text(
                widget.chatRoomId
              )
            ],
          ),
        )
      ),
    );
  }
}