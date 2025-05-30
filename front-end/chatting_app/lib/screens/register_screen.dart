import 'dart:developer';

import 'package:chatting_app/utils/checkValidate.dart';
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

  // 값 입력 여부
  bool isIdInput = false;
  bool isNickNameInput = false;

  // 중복확인 여부
  bool idNotDuplication = false;
  bool nickNameNotDuplication = false;

  // 상태값
  bool isIdValid = false;
  bool isPasswordValid = false;
  bool isRePasswordValid = false;
  bool isNickNameValid = false;

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

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data: $data");
        bool isDuplication = data["bool"];

        setState(() {
          idNotDuplication = !isDuplication;
          isIdValid = !isDuplication;
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

  // 닉네임 중복확인 요청 함수
  Future<void> checkNickNameDuplication() async {
    String nickName = nickNameController.text;

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/duplication/nickName?nickName=$nickName");
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("data: $data");
        bool isDuplication = data["bool"];

        setState(() {
          nickNameNotDuplication = !isDuplication;
          isNickNameValid = !isDuplication;
        });

        if (nickNameNotDuplication) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("사용 가능한 닉네임입니다."))
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("중복된 닉네임입니다."))
          );
        }
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("닉네임 중복 확인 실패"))
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

  // 회원가입 요청 함수
  Future<void> signUp() async {
    final id = idController.text;
    final password = passwordController.text;
    final nickName = nickNameController.text;

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/signUp");
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          "id": id,
          "password": password,
          "nickName": nickName,
          "profileImage": "default"
        })
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입 성공"))
        );

        Navigator.pop(context);
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입 실패"))
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
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      return Checkvalidate().validateId(value, idNotDuplication);
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        isIdInput = Checkvalidate().checkIdInput(value);
                                        idNotDuplication = false;
                                        isIdValid = Checkvalidate().validateId(value, idNotDuplication) == null;
                                      });
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
                                  onPressed: isIdInput
                                  ? () {
                                      checkIdDuplication();
                                    }
                                  : null,
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
                              obscureText: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                return Checkvalidate().validatePassword(value);
                              },
                              onChanged: (value) {
                                setState(() {
                                  isPasswordValid = Checkvalidate().validatePassword(passwordController.text) == null;  
                                });
                              },
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
                              obscureText: true,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                return Checkvalidate().validateRePassword(passwordController.text, value);
                              },
                              onChanged: (value) {
                                setState(() {
                                  isRePasswordValid = Checkvalidate().validateRePassword(passwordController.text, value) == null;  
                                });
                              },
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
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: nickNameController,
                                    focusNode: nickNameFocus,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      return Checkvalidate().validateNickName(value, nickNameNotDuplication);
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        isNickNameInput = Checkvalidate().checkNickNameInput(nickNameController.text);
                                        nickNameNotDuplication = false;
                                        isNickNameValid = Checkvalidate().validateNickName(value, nickNameNotDuplication) == null;
                                      });
                                    },
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
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: isNickNameInput
                                  ? () {
                                      checkNickNameDuplication();
                                    }
                                  : null,
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
                      )
                    ],
                  )
                ),
              ),
              ElevatedButton(
                onPressed: isIdValid && isPasswordValid && isRePasswordValid && isNickNameValid
                ? () {
                    print("회원가입 버튼 클릭!!!");
                    signUp();
                  }
                : null,
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