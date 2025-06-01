import 'package:flutter/material.dart';

class BroadcastRoomTile extends StatefulWidget {
  final Map<String, dynamic> broadcastRoom;
  final VoidCallback onTap;
  const BroadcastRoomTile({
    super.key,
    required this.broadcastRoom,
    required this.onTap
  });

  @override
  State<BroadcastRoomTile> createState() => _BroadcastRoomTileState();
}

class _BroadcastRoomTileState extends State<BroadcastRoomTile> {
  @override
  Widget build(BuildContext context) {
    final String broadcastRoomName = widget.broadcastRoom["roomName"];
    final String broadcastUserNickName = widget.broadcastRoom["senderNickName"];

    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                broadcastRoomName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "방송인: ",
                  style: TextStyle(
                    fontSize: 16
                  ),
                ),
                Text(
                  broadcastUserNickName,
                  style: TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            )
          ],
        )
      ),
    );
  }
}