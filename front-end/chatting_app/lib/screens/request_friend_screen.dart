import 'package:flutter/material.dart';

class RequestFriendScreen extends StatefulWidget {
  const RequestFriendScreen({super.key});

  @override
  State<RequestFriendScreen> createState() => _RequestFriendScreenState();
}

class _RequestFriendScreenState extends State<RequestFriendScreen> {
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
      body: Column(

      )
    );
  }
}