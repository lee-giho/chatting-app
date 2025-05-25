import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatRoomTile extends StatefulWidget {
  final Map<String, dynamic> chatRoom;
  const ChatRoomTile({
    super.key,
    required this.chatRoom
  });

  @override
  State<ChatRoomTile> createState() => _ChatRoomTileState();
}

class _ChatRoomTileState extends State<ChatRoomTile> {
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> chatRoomInfo = widget.chatRoom["chatRoomInfo"];
    final Map<String, dynamic> friendInfo = widget.chatRoom["friendInfo"];
    final Map<String, dynamic>? lastMessage = widget.chatRoom["lastMessage"];

    final String profileImage = friendInfo["profileImage"] ?? "default";
    final String nickName = friendInfo["nickName"] ?? "";

    return Padding(
      padding: const EdgeInsets.all(8.0),
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
          SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  )
                ),
                Text(
                  lastMessage?["content"] ?? "",
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}