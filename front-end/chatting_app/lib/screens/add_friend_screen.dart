import 'dart:developer';

import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/utils/webSocket.dart';
import 'package:chatting_app/widget/userTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddFriendScreen extends StatefulWidget {
  final String myId;
  const AddFriendScreen({
    super.key,
    required this.myId
  });

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {

  var searchKeywordController = TextEditingController();
  FocusNode searchKeywordFocus = FocusNode();

  List<dynamic> searchUser = [];

  @override
  void initState() {
    super.initState();

    WebSocket().addFriendRequestListener(onFriendReceived);
    WebSocket().addFriendAcceptListener(onFriendReceived);
    WebSocket().addFriendDeclineListener(onFriendReceived);
  }

  @override
  void dispose() {
    super.dispose();

    searchKeywordController.dispose();
    searchKeywordFocus.dispose();

    WebSocket().removeFriendRequestListener(onFriendReceived);
    WebSocket().removeFriendAcceptListener(onFriendReceived);
    WebSocket().removeFriendDeclineListener(onFriendReceived);
  }

  void onFriendReceived(String message) {
    searchUserByKeyword();
  }

  // 검색어로 사용자 검색하기
  Future<void> searchUserByKeyword() async {

    String? accessToken = await SecureStorage.getAccessToken();
    String keyword = searchKeywordController.text;

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/keyword?keyword=$keyword");
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
          searchUser = data["searchUsers"];
        });
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("사용자 검색하기 실패"))
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

  // 친구 요청 보내기
  Future<void> requestFriend(String toUserId) async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/friend/request?toUserId=$toUserId");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.post(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 요청을 보냈습니다."))
        );

        searchUserByKeyword(); // 다시 검색해 요청 여부 적용
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("친구 요청을 실패했습니다."))
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
            "친구 추가",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            searchKeywordFocus.unfocus();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          
            child: Column(
              children: [
                Container( // 검색바
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1
                    ),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchKeywordController,
                          focusNode: searchKeywordFocus,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: const InputDecoration(
                            hintText: "사용자를 검색해보세요.",
                            hintStyle: TextStyle(fontSize: 15),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(121, 55, 64, 0)
                              )
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(122, 11, 11, 0)
                              )
                            )
                          ),
                        ),
                      ),
                      if (searchKeywordController.text.isNotEmpty)
                        IconButton( // 검색어 삭제 부분
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.clear,
                            size: 20,
                          ),
                          onPressed: () {
                            searchKeywordController.clear(); // TextField 내용 비우기
                            setState(() {});
                          },
                        ),
                      IconButton( // 검색 버튼 부분
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.search,
                          size: 20,
                        ),
                        onPressed: () {
                          searchUserByKeyword();
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverList.builder(
                        itemCount: searchUser.length,
                        itemBuilder: (context, index) {
                          final user = searchUser[index];
                          final userInfo = user["userInfo"];
                          final friend = user["friend"];

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: UserTile(
                                  userInfo: userInfo
                                ),
                              ),
                              IconButton(
                                icon: friend != null
                                  ? const Icon( // 친구 요청 아이콘
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : const Icon( // 친구 관계가 없을 때
                                      Icons.add,
                                      color: Colors.black,
                                    ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: BorderSide(
                                      width: 1
                                    )
                                  )
                                ),
                                onPressed: friend != null
                                  ? null
                                  : () { // 친구 관계가 없을 때
                                      requestFriend(userInfo["id"]);
                                    },
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
      ),
    );
  }
}