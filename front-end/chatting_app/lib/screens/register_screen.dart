import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  var idController = TextEditingController();
  var passwordController = TextEditingController();
  var rePasswordController = TextEditingController();
  var nickNameController = TextEditingController(); 

  FocusNode idFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode rePasswordFocus = FocusNode();
  FocusNode nickNameFocus = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool idNotDuplication = false;

  @override
  void dispose() {
    super.dispose();

    idController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    nickNameController.dispose();

    idFocus.dispose();
    passwordFocus.dispose();
    rePasswordFocus.dispose();
    nickNameFocus.dispose();
  }

  // 아이디 중복확인 요청 함수
  Future<void> checkIdDuplication() async {
    String id = idController.text;

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/duplication/id?id=$id");
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data: $data");
        bool isDuplication = data["isDuplication"];

        setState(() {
          idNotDuplication = !isDuplication;
        });

        if (idNotDuplication) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("사용 가능한 아이디입니다."))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("중복된 아이디입니다."))
          );
        }
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("아이디 중복 확인 실패"))
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "회원가입"
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
          child: Column(
            children: [
              Expanded(
                child: Form( // 회원가입 폼
                  key: formKey,
                  child: Column(
                    children: [
                      Container( // 아이디 입력 부분
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "아이디",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: idController,
                                    focusNode: idFocus,
                                    validator: (value) {
                                      
                                    },
                                    decoration: const InputDecoration(
                                      hintText: "아이디를 입력해주세요.",
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Color.fromRGBO(121, 55, 64, 0.612)
                                        )
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(5)
                                        ),
                                        borderSide: BorderSide(
                                          color: Color.fromRGBO(122, 11, 11, 1)
                                        )
                                      )
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    checkIdDuplication();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(100, 50),
                                    backgroundColor: const Color.fromRGBO(122, 11, 11, 1) ,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5)
                                    )
                                  ),
                                  child: const Text(
                                    "중복확인",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold
                                    ),
                                  )
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container( // 비밀번호 입력 부분
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "비밀번호",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            TextFormField(
                              controller: passwordController,
                              focusNode: passwordFocus,
                              decoration: const InputDecoration(
                                hintText: "비밀번호를 입력해주세요.",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                  ),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(121, 55, 64, 0.612)
                                  )
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                  ),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(122, 11, 11, 1)
                                  )
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container( // 비밀번호 재입력 부분
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "비밀번호 확인",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            TextFormField(
                              controller: rePasswordController,
                              focusNode: rePasswordFocus,
                              decoration: const InputDecoration(
                                hintText: "비밀번호를 다시 입력해주세요.",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                  ),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(121, 55, 64, 0.612)
                                  )
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                  ),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(122, 11, 11, 1)
                                  )
                                )
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Container( // 닉네임 입력 부분
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "닉네임",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            TextFormField(
                              controller: nickNameController,
                              focusNode: nickNameFocus,
                              decoration: const InputDecoration(
                                hintText: "닉네임을 입력해주세요.",
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                  ),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(121, 55, 64, 0.612)
                                  )
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5)
                                  ),
                                  borderSide: BorderSide(
                                    color: Color.fromRGBO(122, 11, 11, 1)
                                  )
                                )
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  print("회원가입 버튼 클릭!!!");
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: const Color.fromRGBO(122, 11, 11, 1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                child: Text(
                  "회원가입",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                  ),
                )
              )
            ],
          ),
        )
      ),
    );
  }
}