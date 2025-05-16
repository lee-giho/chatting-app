import 'dart:developer';

import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/utils/webSocket.dart';
import 'package:chatting_app/widget/userTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestFriendScreen extends StatefulWidget {
  final VoidCallback getRequestFriendCount;
  final VoidCallback getFriendList;
  const RequestFriendScreen({
    super.key,
    required this.getRequestFriendCount,
    required this.getFriendList
  });

  @override
  State<RequestFriendScreen> createState() => _RequestFriendScreenState();
}

class _RequestFriendScreenState extends State<RequestFriendScreen> {

  List<dynamic> receivedFriendRequests = [];

  @override
  void initState() {
    super.initState();

    getReceivedFriendRequests();

    WebSocket().addVoidFunctionListener(onRefreshScreen);
  }

  @override
  void dispose() {
    super.dispose();

    WebSocket().removeVoidFunctionListener(onRefreshScreen);
  }

  void onRefreshScreen() {
    getReceivedFriendRequests();
  }

  Future<void> getReceivedFriendRequests() async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend/requests");
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
          receivedFriendRequests = data["receivedFriendRequests"];
        });

      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("받은 친구 요청 불러오기 실패"))
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

  Future<void> acceptFriend(String toUserId) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend/accept?toUserId=$toUserId");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.post(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        log("acceptFriend: ${response.body}");

        await getReceivedFriendRequests(); // 친구 요청 리스트 새로고침
        widget.getRequestFriendCount(); // 이전 화면에서 친구 요청 수 새로고침
        widget.getFriendList(); // 이전 화면에서 친구 리스트 새로고침

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 요청을 수락했습니다."))
        );
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 요청 수락을 실패했습니다.."))
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

  Future<void> declineFriend(String toUserId) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend/decline?toUserId=$toUserId");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.delete(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        log("acceptFriend: ${response.body}");

        await getReceivedFriendRequests(); // 친구 요청 리스트 새로고침
        widget.getRequestFriendCount(); // 이전 화면에서 친구 요청 수 새로고침

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 요청을 거절했습니다."))
        );
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 요청 수락을 실패했습니다.."))
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
            "친구 요청",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),

          child: Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverList.builder(
                      itemCount: receivedFriendRequests.length,
                      itemBuilder: (context, index) {
                        final userInfo = receivedFriendRequests[index]["userInfo"];
                        final friend = receivedFriendRequests[index]["friend"];
          
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: UserTile(
                                userInfo: userInfo,
                                isMine: false,
                                isFriend: false,
                              ),
                            ),
                            Row( // 수락, 거절 버튼 부분
                              children: [
                                TextButton( // 수락 버튼
                                  onPressed: () {
                                    acceptFriend(friend["userId"]);
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    )
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 24,
                                      ),
                                      Text(
                                        "수락",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12
                                        ),
                                      )
                                    ],
                                  )
                                ),
                                TextButton( // 거절 버튼
                                  onPressed: () {
                                    declineFriend(friend["userId"]);
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    )
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 24,
                                      ),
                                      Text(
                                        "거절",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 12
                                        ),
                                      )
                                    ],
                                  )
                                )
                              ],
                            )
                          ],
                        );
                      }
                    )
                  ],
                )
              )
            ],
          ),
        ),
      )
    );
  }
}