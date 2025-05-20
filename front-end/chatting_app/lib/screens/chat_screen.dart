import 'package:chatting_app/widget/chatMessageBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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

  List<dynamic> chatMessageList = [
    {
      "id" : "a",
      "content" : "1111"
    },
    {
      "id" : "b",
      "content" : "2222"
    },
    {
      "id" : "b",
      "content" : "asdfasdfasdfkjl;ahsdl;fa;ldfjl;ajdfl;ajdl;fjasdfhakjsdhfjkahdsfkhakjsdhfjahsdkfjhsdjkfhjkhjkahsdflkjhasldkjfhkljh"
    }
  ];

  @override
  void dispose() {
    super.dispose();

    messageController.dispose();

    messageFocus.dispose();
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