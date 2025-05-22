import 'package:chatting_app/utils/screen_size.dart';
import 'package:flutter/material.dart';

class ChatMessageBox extends StatefulWidget {
  final Map<String, dynamic> chatMessage;
  final bool isMine;
  const ChatMessageBox({
    super.key,
    required this.chatMessage,
    required this.isMine
  });

  @override
  State<ChatMessageBox> createState() => _ChatMessageBoxState();
}

class _ChatMessageBoxState extends State<ChatMessageBox> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMine
        ? Alignment.centerRight
        : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: ScreenSize().width * 0.5
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.isMine
              ? const Color.fromARGB(255, 176, 255, 179)
              : const Color.fromARGB(255, 255, 231, 159),
            border: Border.all(
              width: 1
            ),
            borderRadius: BorderRadius.circular(5)
          ),
          child: Text(
            widget.chatMessage["content"],
            style: TextStyle(
              fontSize: 16
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ),
    );
  }
}