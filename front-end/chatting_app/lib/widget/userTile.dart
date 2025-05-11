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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(width: 1),
              borderRadius: BorderRadius.circular(25)
            ),
            child: profileImage == "default"
            ? const Padding(
                padding: EdgeInsets.all(3.0),
                child: Icon(
                  Icons.person,
                  size: 44,
                ),
              )
            : CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(
                "${dotenv.env["API_ADDRESS"]}/images/profile/${profileImage}"
              ),
            )
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