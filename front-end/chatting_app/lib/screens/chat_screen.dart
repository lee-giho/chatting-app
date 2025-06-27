import 'dart:developer';

import 'package:chatting_app/screens/video_call_screen.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/widget/chatMessageBox.dart';
import 'package:chatting_app/widget/userTile.dart';
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
    getUsersInfo().then((_) async {
      await getChatMessageList(); // 메시지 불러오기
      await markUnreadMessageAsRead(); // 채팅방 들어왔을 때 읽음 처리
    });
    
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

                // 수신 메시지 읽음 처리
                if (decodedData["sender"] != myInfo["id"]) {
                  sendReadReceipt(decodedData["id"]);
                }

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

          stompClient.subscribe(
            destination: "/topic/chat-room/read/${widget.chatRoomId}",
            callback: (frame) {
              final body = frame.body;
              if (body != null) {
                final data = json.decode(body);
                log("AAAAASDFASDF: $data");
                final String messageId = data["messageId"];
                final String readerId = data["readerId"];

                setState(() {
                  final msg = chatMessageList.firstWhere(
                    (msg) => msg["id"] == messageId,
                    orElse: () => null
                  );
                  if (msg != null) {
                    final List<dynamic> readByList = msg["readBy"];
                    if (!readByList.contains(readerId)) {
                      readByList.add(readerId);
                    }
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
        "roomId": widget.chatRoomId,
        "friendId": friendInfo["id"]
      }),
      headers: {
        'Authorization': 'Bearer $accessToken'
      }
    );
    
    setState(() {
      messageController.clear();
    });
  }

  Future<void> sendReadReceipt(String messageid) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/chatMessage/read?messageId=$messageid");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.post(
        apiAddress,
        headers: headers
      );

      if (response.statusCode != 200) {
        log("읽음 처리 실패: ${response.statusCode}");
      }
    } catch (e) {
      log("읽음 처리 에러: $e");
    }
  }

  Future<void> markUnreadMessageAsRead() async {
    for (var msg in List.from(chatMessageList)) {
      print("msg: $msg");
      final readByList = msg["readBy"];
      final sender = msg["sender"];
      final id = msg["id"];

      if (sender != null &&
          sender != myInfo["id"] &&
          !readByList.contains(myInfo["id"])
      ) {
        await sendReadReceipt(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: Text(
          widget.chatRoomId,
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          )
        ],
      ),
      endDrawer: Drawer(
        child: SafeArea(
          child: Container(
            color: Colors.grey[300],
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "대화상대",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Column( // 채팅방 사용자
                              children: [
                                UserTile(
                                  userInfo: myInfo,
                                  isMine: true,
                                  isFriend: false,
                                  onEnterChatRoom: (_) {} 
                                ),
                                UserTile(
                                  userInfo: friendInfo,
                                  isMine: true,
                                  isFriend: false,
                                  onEnterChatRoom: (_) {} 
                                )
                              ]
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "메뉴",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    ClipOval(
                                      child: Material(
                                        color: Colors.green,
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => VideoCallScreen(
                                                  chatRoomId: widget.chatRoomId,
                                                )
                                              )
                                            );
                                          },
                                          child: SizedBox(
                                            width: 48,
                                            height: 48,
                                            child: Icon(
                                              Icons.call,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text("영상통화")
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onPressed: () {},
                  ),
                )
              ]
            ),
          )
        )
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
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: chatMessageList.length,
                    itemBuilder: (context, index) {
                      final chatMessage = chatMessageList[index];
                      return ChatMessageBox(
                        key: ValueKey(chatMessage["id"]),
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