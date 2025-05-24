import 'dart:developer';

import 'package:chatting_app/screens/chat_screen.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/widget/chatRoomTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatRoomListScreen extends StatefulWidget {
  const ChatRoomListScreen({super.key});

  @override
  State<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {

  // 채팅방 리스트
  List<dynamic> chatRoomList = [];

  @override
  void initState() {
    super.initState();

    getChatRoomList();
  }

  Future<void> getChatRoomList() async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/chatRoom");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["chatRoomInfos"] != null) {
          setState(() {
          chatRoomList = data["chatRoomInfos"];
        });
        }
        print("chatRoomList: $chatRoomList");
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("채팅방 목록 불러오기 실패"))
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

  Future<void> deleteChatRoom(String chatRoomId) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/chatRoom?chatRoomId=$chatRoomId");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.delete(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        bool result = data["bool"];
        if (result) {
          getChatRoomList();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("채팅방이 삭제되었습니다."))
          );
        }
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("채팅방 삭제하기 실패"))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            "채팅목록",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container( // 전체 화면
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList.builder(
                      itemCount: chatRoomList.length,
                      itemBuilder: (context, index) {
                        final chatRoom = chatRoomList[index];
                        final String chatRoomId = chatRoom["chatRoomInfo"]["id"];
                        return Slidable(
                          key: ValueKey(chatRoomId),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.25,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  deleteChatRoom(chatRoomId);
                                },
                                backgroundColor: Colors.red,
                                flex: 1,
                                icon: Icons.delete,
                                label: "나가기",
                              )
                            ]
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreen(
                                    chatRoomId: chatRoomId
                                  )
                                )
                              );
                            },
                            child: ChatRoomTile(
                              chatRoom: chatRoom
                            ),
                          )
                        );
                      }
                    )
                  ],
                )
              ),
            ],
          ),
        )
      ),
    );
  }
}