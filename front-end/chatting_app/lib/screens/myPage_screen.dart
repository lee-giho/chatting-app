import 'dart:developer';

import 'package:chatting_app/utils/secureStorage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:image_picker/image_picker.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {

  // 내정보
  Map<String, dynamic> myInfo = {};

  @override
  void initState() {
    super.initState();
    getMyInfo();
  }

  // 내정보 요청 함수
  Future<void> getMyInfo() async {

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/myInfo");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data: $data");
        setState(() {
          myInfo = data;
        });
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("내정보 가져오기 실패"))
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

  // 프로필 사진 변경 요청 함수
  Future<void> uploadProfileImage(XFile pickedImage) async {

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/profileImage");

    final request = http.MultipartRequest('post', apiAddress);
    request.headers["Authorization"] = 'Bearer $accessToken';

    request.files.add(await http.MultipartFile.fromPath(
      'profileImage',
      pickedImage.path
    ));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        await getMyInfo();
        ScaffoldMessenger.of(context)
          .showSnackBar(
            const SnackBar(
              content: Text("프로필 이미지가 변경되었습니다.")
            )
          );
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("프로필 이미지가 변경되지 않았습니다."))
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

  // 프로필 사진 기본으로 변경 요청 함수
  Future<void> resetToDefaultProfileImage() async {

    String? accessToken = await SecureStorage.getAccessToken();

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/user/profileImage/default");
    final headers = {'Authorization': 'Bearer $accessToken'};

    try {
      final response = await http.delete(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        await getMyInfo();
        ScaffoldMessenger.of(context)
          .showSnackBar(
            const SnackBar(
              content: Text("프로필 이미지가 변경되었습니다.")
            )
          );
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("프로필 이미지가 변경되지 않았습니다."))
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

  // 프로필 사진 선택 팝업창
  void showProfileImageOptions() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Dialog(
          insetPadding: const EdgeInsets.all(30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "프로필 사진 선택",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.image,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "갤러리에서 선택",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.black,
                    foregroundColor: const Color.fromRGBO(122, 11, 11, 1),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1
                      ),
                      borderRadius: BorderRadius.circular(15)
                    )
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final pickedImage = await picker.pickImage(
                      source: ImageSource.gallery
                    );
                    if (pickedImage != null) {
                      uploadProfileImage(pickedImage);
                    }
                  }
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  label: const Text(
                    "기본 이미지 선택",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.black,
                    foregroundColor: const Color.fromRGBO(122, 11, 11, 1),
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10
                    ),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1
                      ),
                      borderRadius: BorderRadius.circular(15)
                    )
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    resetToDefaultProfileImage();
                  }
                )
              ],
            ),
          ),
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    print("myInfo: $myInfo");
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: const Text(
            "설정",
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(25, 0, 25, 0),
          child: Column(
            children: [
              Container( // 내정보
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: myInfo.isEmpty
                ? const CircularProgressIndicator()
                : Column(
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        showProfileImageOptions();
                      },
                      child: CircleAvatar( // 프로필 사진
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: myInfo["profileImage"] != "default"
                          ? NetworkImage(
                              "${dotenv.env["API_ADDRESS"]}/images/profile/${myInfo["profileImage"]}"
                            )
                          : null,
                        child: myInfo["profileImage"] == "default"
                          ? Icon(
                              Icons.person,
                              size: 84,
                            )
                          : null
                      ),
                    ),
                    SizedBox(height: 30),
                    Container( // 이름
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Colors.grey
                          )
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "아이디",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            myInfo["id"],
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Container( // 닉네임
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Colors.grey
                          )
                        )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "닉네임",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          Text(
                            myInfo["nickName"],
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }
}