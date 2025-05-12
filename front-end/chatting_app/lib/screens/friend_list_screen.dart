import 'dart:developer';

import 'package:chatting_app/screens/add_friend_screen.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/utils/webSocket.dart';
import 'package:chatting_app/widget/userTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {

  Map<String, dynamic> myInfo = {};

  @override
  void initState() {
    super.initState();
    getMyInfo();
    WebSocket().addFriendRequestListener(onFriendRequestReceived);
  }

  @override
  void dispose() {
    super.dispose();
    WebSocket().removeFriendRequestListener(onFriendRequestReceived);
  }

  void onFriendRequestReceived(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  // 내정보 요청 함수
  Future<void> getMyInfo() async {

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/myInfo");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data: $data");
        setState(() {
          myInfo = data;
        });
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("내정보 가져오기 실패"))
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "친구목록",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.person_add,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddFriendScreen()
                    )
                  );
                },
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
            children: [
              UserTile(
                userInfo: {
                  "profileImage": myInfo["profileImage"] ?? "default",
                  "nickName": myInfo["nickName"] ?? ""
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}