import 'package:chatting_app/widget/userProfile.dart';
import 'package:flutter/material.dart';

class ShowModal {
  void showUserProfile(BuildContext context, Map<String, dynamic> userInfo, bool isMine, bool isFriend) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 1, // 전체 화면
          child: Userprofile(
            userInfo: userInfo,
            isMine: isMine,
            isFriend: isFriend,
          ),
        );
      }
    );
  }
}