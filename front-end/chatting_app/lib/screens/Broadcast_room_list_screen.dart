import 'dart:developer';

import 'package:chatting_app/screens/broadcast_live_screen.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/utils/webSocket.dart';
import 'package:chatting_app/widget/broadcastRoomTile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:uuid/uuid.dart';

class BroadcastRoomListScreen extends StatefulWidget {
  const BroadcastRoomListScreen({super.key});

  @override
  State<BroadcastRoomListScreen> createState() => _BroadcastRoomListScreenState();
}

class _BroadcastRoomListScreenState extends State<BroadcastRoomListScreen> {

  List<dynamic> broadcastRoomList = [];

  @override
  void initState() {
    super.initState();
    
    getBroadcastRooms();
  }

  Future<void> getBroadcastRooms() async {
    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/broadcast");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["broadcastRoomInfoList"] != null) {
          setState(() {
            broadcastRoomList = data["broadcastRoomInfoList"];
          });
        }
        print("broadcastRoomInfoList: $broadcastRoomList");
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("브로드캐스트 방 목록 불러오기 실패"))
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

  Future<void> createBroadcastRoom(String roomName) async {
    String? accessToken = await SecureStorage.getAccessToken();
    final newRoomId = const Uuid().v4();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/broadcast");
    final headers = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json'
    };

    try {
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          "roomId": newRoomId,
          "roomName": roomName
        })
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final broadcastRoomInfo = json.decode(response.body);
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BroadcastLiveScreen(
              broadcastRoomInfo: broadcastRoomInfo,
            )
          )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("브로드캐스트 방이 만들어지지 않았습니다."))
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

  void showCreateRoomDialog() {
    final roomNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("방송 제목 입력"),
        content: TextField(
          controller: roomNameController
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("취소")
          ),
          TextButton(
            onPressed: () async {
              final roomName = roomNameController.text.trim();
              Navigator.of(context).pop();
              await createBroadcastRoom(roomName);
            },
            child: Text("시작")
          )
        ],
      )
    );
  }

  Future<void> enterBroadcastRoom(String roomId) async {
    print(roomId);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("라이브 목록"),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: getBroadcastRooms,
          color: const Color.fromRGBO(138, 50, 50, 1),
          child: Container( // 전체 화면
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
            child: broadcastRoomList.isEmpty
              ? const Center(
                child: Text(
                  "현재 라이브 중인 사람이 없습니다."
                ),
              ) 
            : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverList.builder(
                        itemCount: broadcastRoomList.length,
                        itemBuilder: (context, index) {
                          final broadcastRoom = broadcastRoomList[index];
                          print("broadcastRoom: $broadcastRoom");
                          final String broadcastRoomId = broadcastRoom["roomId"];
                          return BroadcastRoomTile(
                            broadcastRoom: broadcastRoom,
                            onTap: () => enterBroadcastRoom(broadcastRoomId),
                          );
                        }
                      )
                    ],
                  )
                ),
              ],
            ),
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(138, 50, 50, 1),
        onPressed: showCreateRoomDialog,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
        tooltip: "방송 시작하기",
      ),
    );
  }
}