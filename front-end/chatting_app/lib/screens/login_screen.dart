import 'dart:developer';

import 'package:chatting_app/screens/main_screen.dart';
import 'package:chatting_app/screens/register_screen.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/utils/webSocket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  var idController = TextEditingController();
  var passwordController = TextEditingController();

  FocusNode idFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // 값 입력 여부
  bool isIdInput = false;
  bool isPasswordInput = false;

  // 자동 로그인 여부
  bool? isAutoLogin = false;

  @override
  void dispose() {
    super.dispose();

    idController.dispose();
    passwordController.dispose();

    idFocus.dispose();
    passwordFocus.dispose();
  }

  // 로그인 함수
  Future<void> login() async {
    String id = idController.text;
    String password = passwordController.text;

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/auth/login");
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          "id": id,
          "password": password
        })
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print(data);
        String accessToken = data["accessToken"];
        String refreshToken = data["refreshToken"];

        // SecureStorage에 값 저장
        await SecureStorage.saveAccessToken(accessToken);
        await SecureStorage.saveRefreshToken(refreshToken);
        await SecureStorage.saveIsAutoLogin(isAutoLogin);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인 성공"))
        );

        // 친구 요청 알림 WebSocket 연결
        Websocket().connectToWebSocket(id);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen()
          )
        );
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인 실패"))
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
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
          // color: Colors.amber,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                // color: Colors.blue,
                child: Center(
                  child: Text(
                    "로그인",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
              Expanded( // 로그인 부분
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Form(
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
                                TextFormField(
                                  controller: idController,
                                  focusNode: idFocus,
                                  onChanged: (value) {
                                    setState(() {
                                      isIdInput = idController.text.trim().isNotEmpty;
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
                                  onChanged: (value) {
                                    setState(() {
                                      isPasswordInput = passwordController.text.trim().isNotEmpty;
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
                          )
                        ],
                      )
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Container( // 자동 로그인 체크박스
                          child: Row(
                            children: [
                              Checkbox(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)
                                ),
                                value: isAutoLogin,
                                onChanged: (value) {
                                  setState(() {
                                    isAutoLogin = value;
                                  });
                                }
                              ),
                              const Text(
                                "로그인 상태 유지",
                                style: TextStyle(
                                  fontSize: 18
                                ),
                              )
                            ],
                          ),
                        ),
                        Container( // 로그인 버튼
                          child: ElevatedButton(
                            onPressed: isIdInput && isPasswordInput
                            ? () {
                                print("로그인 버튼 클릭!!!");
                                login();
                              }
                            : null,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor:const Color.fromRGBO(122, 11, 11, 1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)
                              )
                            ),
                            child: const Text(
                              "로그인",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            )
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        TextButton(
                          onPressed: () {
                            print("회원가입 클릭!!!");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen()
                              )
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white
                          ),
                          child: const Text(
                            "회원가입",
                            style: TextStyle(
                              color: Colors.black
                            ),
                          )
                        ),
                      ],
                    )
                  ],
                )
              )
            ],
          ),
        )
      ),
    );
  }
}