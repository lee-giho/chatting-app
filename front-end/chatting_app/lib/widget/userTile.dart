import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserTile extends StatefulWidget {
  final Map<String, dynamic> userInfo;
  const UserTile({
    super.key,
    required this.userInfo
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    final String profileImage = widget.userInfo["profileImage"];
    final String nickName = widget.userInfo["nickName"];
    return InkWell(
      onTap: () {
        print("$nickName 클릭");
      },
      child: Row(
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
          )
        ],
      ),
    );
  }
}