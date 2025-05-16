import 'dart:developer';

import 'package:chatting_app/screens/add_friend_screen.dart';
import 'package:chatting_app/screens/request_friend_screen.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/utils/webSocket.dart';
import 'package:chatting_app/widget/userTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FriendListScreen extends StatefulWidget {
  const FriendListScreen({super.key});

  @override
  State<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends State<FriendListScreen> {

  // 내 정보
  Map<String, dynamic> myInfo = {};

  // 친구 요청 수
  int requestFriendCount = 0;
  List<dynamic> friendList = [];

  // 클릭한 유저
  Map<String, dynamic> tapUser = {};

  @override
  void initState() {
    super.initState();

    getMyInfo();
    getRequestFriendCount();
    getFriendList();

    WebSocket().addShowMessageListener(onShowMessage);
  }

  @override
  void dispose() {
    super.dispose();

    WebSocket().removeShowMessageListener(onShowMessage);
  }

  // 웹소켓 메시지 알림
  void onShowMessage(String message) {
    getRequestFriendCount();
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

  // 친구 요청 수 불러오는 함수
  Future<void> getRequestFriendCount() async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend/count");
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
          requestFriendCount = data["count"];
        });
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 요청 수 불러오기 실패"))
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

  Future<void> getFriendList() async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend/list");
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
          friendList = data["friends"];
        });
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 목록 불러오기 실패"))
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

  Future<void> deleteFriend(String friendId) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend?friendId=$friendId");
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
        print("data: $data");
        if (result) {
          getFriendList();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("친구가 삭제되었습니다."))
          );
        }
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 삭제하기 실패"))
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
                      builder: (context) => AddFriendScreen(
                        myId: myInfo["id"],
                        getRequestFriendCount: getRequestFriendCount,
                      )
                    )
                  );
                },
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Container( // 전체 화면
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
            children: [
              UserTile(
                userInfo: myInfo,
                isMine: true,
                isFriend: false,
              ),
              Container( // 가로줄
                width: double.infinity,
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              InkWell( // 친구요청 타일
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestFriendScreen(
                        getRequestFriendCount: getRequestFriendCount,
                        getFriendList: getFriendList,
                      )
                    )
                  );
                },
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              
                              child: Icon(
                                Icons.group_add,
                                size: 34,
                                color: Colors.black,
                              )
                            ),
                            SizedBox(width: 20),
                            const Text(
                              "친구요청",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              requestFriendCount.toString()
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container( // 가로줄
                width: double.infinity,
                child: Divider(
                  color: Colors.grey,
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "친구 ${friendList.length.toString()}",
                  ),
                ),
              ),
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList.builder(
                    itemCount: friendList.length,
                    itemBuilder: (context, index) {
                      final friend = friendList[index];
                      return Slidable(
                        key: ValueKey(friend["id"]),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.2,
                          children: [
                            SlidableAction(
                              onPressed: (context) {
                                deleteFriend(friend["id"]);
                              },
                              backgroundColor: Colors.red,
                              flex: 1,
                              icon: Icons.delete,
                              label: "삭제",
                            )
                          ]
                        ),
                        child: UserTile(
                          userInfo: friend,
                          isMine: false,
                          isFriend: true,
                        ),
                      );
                    }
                  )
                  ],
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}