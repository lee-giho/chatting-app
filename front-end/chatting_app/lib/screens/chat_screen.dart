import 'dart:developer';

import 'package:chatting_app/screens/video_call_screen.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/widget/chatMessageBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  final ScrollController scrollController = ScrollController();
  FocusNode messageFocus = FocusNode();

  List<dynamic> chatMessageList = [];
  Map<String, dynamic> myInfo = {};
  Map<String, dynamic> friendInfo = {};
  String creatorId = "";

  late StompClient stompClient;

  @override
  void initState() {
    super.initState();

    chatConnect();
    getUsersInfo();
    getChatMessageList();

    // messageFocus 발생했을 때 아래로 스크롤
    messageFocus.addListener(() {
      if (messageFocus.hasFocus) {
        Future.delayed(Duration(milliseconds: 500), () {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: Duration(microseconds: 300),
              curve: Curves.easeOut
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    messageController.dispose();
    messageFocus.dispose();
    stompClient.deactivate();
  }

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
              final body = frame.body;
              if (body != null) {
                final decodedData = jsonDecode(body);
                print("응답 데이터: $decodedData");
                setState(() {
                  chatMessageList.add(decodedData);
                });

                // 프레임 렌더링 후 스크롤 아래로 이동
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (scrollController.hasClients) {
                    scrollController.animateTo(
                      scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut
                    );
                  }
                });
              }
            }
          );
        }
      )
    );

    stompClient.activate();
  }

  Future<void> getUsersInfo() async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/chatRoom/usersInfo?chatRoomId=${widget.chatRoomId}");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        setState(() {
          myInfo = data["myInfo"];
          friendInfo = data["friendInfo"];
          creatorId = data["creatorId"];
        });
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("사용자 정보 불러오기 실패"))
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

  Future<void> getChatMessageList() async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/chatMessage/all?chatRoomId=${widget.chatRoomId}");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          chatMessageList = data["chatMessageList"];
        });

        // 프레임 렌더링 후 스크롤 아래로 이동
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(
              scrollController.position.maxScrollExtent
            );
          }
        });
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("메세지 목록 불러오기 실패"))
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
                // Expanded( // 메시지 보는 곳
                //   child: CustomScrollView(
                //     slivers: [
                //       SliverList.builder(
                //         itemCount: chatMessageList.length,
                //         itemBuilder: (context, index) {
                //           final chatMessage = chatMessageList[index];
                //           return ChatMessageBox(
                //             chatMessage: chatMessage,
                //             isMine: chatMessage["sender"] == myInfo["id"],
                //           );
                //         }
                //       )
                //     ],
                //   ),
                // ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoCallScreen(
                          roomId: widget.chatRoomId
                        )
                      )
                    );
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: Size(64, 56),
                    backgroundColor: Color.fromRGBO(121, 55, 64, 1)
                  ),
                  child: const Text(
                    "영상통화",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: chatMessageList.length,
                    itemBuilder: (context, index) {
                      final chatMessage = chatMessageList[index];
                      return ChatMessageBox(
                        chatMessage: chatMessage,
                        isMine: chatMessage["sender"] == myInfo["id"]
                      );
                    }
                  )
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