import 'package:chatting_app/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Userprofile extends StatelessWidget {
  final Map<String, dynamic> userInfo;
  final bool isMine;
  final bool isFriend;
  const Userprofile({
    super.key,
    required this.userInfo,
    required this.isMine,
    required this.isFriend
  });

  @override
  Widget build(BuildContext context) {
    final userId = userInfo["id"] ?? "";
    final nickName = userInfo["nickName"] ?? "";
    final profileImage = userInfo["profileImage"] ?? "default";

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[400],
      ),
      width: ScreenSize().width,
      height: ScreenSize().height,
      child: Container(
        decoration: BoxDecoration(
          image: profileImage != "default"
          ? DecorationImage(
              image: NetworkImage(
                "${dotenv.env["API_ADDRESS"]}/images/profile/${profileImage}",
              ),
              fit: BoxFit.cover
            )
          : null
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: ScreenSize().height*0.05,
            horizontal: ScreenSize().width*0.05
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  )
                ),
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 40,
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
                  const SizedBox(height: 10),
                  Text(
                    nickName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isFriend)
                    TextButton(
                      onPressed: () {

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
                    )
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}