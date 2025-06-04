import 'package:chatting_app/screens/broadcast_room_list_screen.dart';
import 'package:chatting_app/screens/chat_room_list_screen.dart';
import 'package:chatting_app/screens/friend_list_screen.dart';
import 'package:chatting_app/screens/myPage_screen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  int currentIndex = 0;

  void changeTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> screens = [
      FriendListScreen(
        changeTab: changeTab,
      ),
      ChatRoomListScreen(),
      BroadcastRoomListScreen(),
      MyPageScreen()
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          changeTab(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 30,
            ),
            label: "친구"
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat,
              size: 30,
            ),
            label: "채팅방"
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.videocam,
              size: 30,
            ),
            label: "라이브"
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              size: 30,
            ),
            label: "마이페이지"
          )
        ],
        selectedItemColor: const Color.fromRGBO(138, 50, 50, 1),
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}