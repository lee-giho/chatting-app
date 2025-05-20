import 'package:flutter/material.dart';

class ChatMessageBox extends StatefulWidget {
  final Map<String, dynamic> chatMessage;
  const ChatMessageBox({
    super.key,
    required this.chatMessage
  });

  @override
  State<ChatMessageBox> createState() => _ChatMessageBoxState();
}

class _ChatMessageBoxState extends State<ChatMessageBox> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth * 0.7 // 화면의 70%
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1
              ),
              borderRadius: BorderRadius.circular(5),
              color: Colors.amber
            ),
            padding: const EdgeInsets.all(8),
            child: Text(
              widget.chatMessage["content"],
              style: TextStyle(
                fontSize: 16  
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        );
      }
    );
  }
}