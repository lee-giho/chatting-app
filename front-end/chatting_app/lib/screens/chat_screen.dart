import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/widget/chatMessageBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';

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

  var messageController = TextEditingController();

  FocusNode messageFocus = FocusNode();

  Map<String, dynamic> chatMessageList = {};

  @override
  void initState() {
    super.initState();

    chatConnect();
  }

  @override
  void dispose() {
    super.dispose();

    messageController.dispose();
    messageFocus.dispose();
    stompClient.deactivate();
  }

  late StompClient stompClient;

  void chatConnect() {
    final wsAddress = dotenv.get("WS_ADDRESS");

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws-chat",
        onConnect: (StompFrame frame) {
          print("연결 성공");
          stompClient.subscribe(
            destination: "/topic/chat-room/${widget.chatRoomId}",
            callback: (frame) {
              final message = frame.body ?? "";
              print("결과: $message");
            }
          );
        }
      )
    );

    stompClient.activate();
  }

  Future<void> sendMessage(String message) async {
    String? accessToken = await SecureStorage.getAccessToken();

    stompClient.send(
      destination: "/app/chat.send",
      body: json.encode({
        "content": message,
        "roomId": widget.chatRoomId
      }),
      headers: {
        'Authorization': 'Bearer $accessToken'
      }
    );
    
    setState(() {
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            widget.chatRoomId,
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            messageFocus.unfocus();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: Column(
              children: [
                Expanded( // 메시지 보는 곳
                  child: CustomScrollView(
                    slivers: [
                      SliverList.builder(
                        itemCount: chatMessageList.length,
                        itemBuilder: (context, index) {
                          final chatMessage = chatMessageList[index];
                          final String chatMessageId = chatMessage["id"];
                          return ChatMessageBox(
                            chatMessage: chatMessage
                          );
                        }
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        focusNode: messageFocus,
                        maxLines: 3,
                        minLines: 1,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5)
                            ),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(121, 55, 64, 0.612)
                            )
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(5)
                            ),
                            borderSide: BorderSide(
                              color: Color.fromRGBO(122, 11, 11, 1)
                            )
                          )
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        sendMessage(messageController.text);
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        minimumSize: Size(64, 56),
                        backgroundColor: Color.fromRGBO(121, 55, 64, 1)
                      ),
                      child: const Text(
                        "전송",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      )
                    )
                  ],
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}