import 'dart:developer';

import 'package:chatting_app/utils/secureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatButton extends StatelessWidget {
  final String friendId;
  final void Function(String result) onEnterChatRoom;
  const ChatButton({
    super.key,
    required this.friendId,
    required this.onEnterChatRoom
  });

  @override
  Widget build(BuildContext context) {

    Future<String> enterChatRoom() async {
      String? accessToken = await SecureStorage.getAccessToken();

      // .env에서 서버 주소 가져오기
      final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/chatRoom?friendId=$friendId");
      final headers = {'Authorization': 'Bearer $accessToken'};

      try {
        final response = await http.post(
          apiAddress,
          headers: headers,
        );

        log("response data = ${utf8.decode(response.bodyBytes)}");

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          return data["chatRoomId"];
        } else {
          log(response.body);

          return "채팅방 생성 실패";
        }
      } catch (e) {
        // 예외 처리
        log(e.toString());

        return "네트워크 오류";
      }
    }

    return TextButton(
      onPressed: () async {
        String result = await enterChatRoom();

        if (result == "채팅방 생성 실패" || result == "네트워크 오류") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result))
          );
        } else {
          onEnterChatRoom(result);
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const Color.fromARGB(0, 146, 144, 144)
      ),
      child: Column(
        children: [
          Icon(
            Icons.message,
            size: 40,
            color: Colors.white,
          ),
          Text(
            "채팅하기",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white
            ),
          )
        ],
      )
    );
  }
}