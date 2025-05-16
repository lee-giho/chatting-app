import 'package:chatting_app/utils/showModal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserTile extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  final void Function(String result) onEnterChatRoom;
  final bool isMine;
  final bool isFriend;
  const UserTile({
    super.key,
    required this.userInfo,
    required this.isMine,
    required this.isFriend,
    required this.onEnterChatRoom
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {

  

  @override
  Widget build(BuildContext context) {
    print("userInfoasdfasdf: ${widget.userInfo}");
    final String profileImage = widget.userInfo["profileImage"] ?? "default";
    final String nickName = widget.userInfo["nickName"] ?? "";

    return InkWell(
      onTap: () async {
        print("$nickName 클릭");
        final result = await ShowModal().showUserProfile(
          context,
          widget.userInfo,
          widget.isMine,
          widget.isFriend
        );

        if (result != null) {
          widget.onEnterChatRoom(result);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Row( // 사용자 정보
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: profileImage != "default"
                    ? NetworkImage(
                        "${dotenv.env["API_ADDRESS"]}/images/profile/${profileImage}"
                      )
                    : null,
                  child: profileImage == "default"
                    ? Icon(
                        Icons.person,
                        size: 34,
                      )
                    : null
                ),
                SizedBox(width: 20),
                Text(
                  nickName,
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}