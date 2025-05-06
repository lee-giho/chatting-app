import 'package:chatting_app/screens/register_screen.dart';
import 'package:flutter/material.dart';

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

  @override
  void dispose() {
    super.dispose();

    idController.dispose();
    passwordController.dispose();

    idFocus.dispose();
    passwordFocus.dispose();
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
                    SizedBox(height: 30),
                    Container(
                      child: ElevatedButton(
                        onPressed: () {
                          print("로그인 버튼 클릭!!!");
                        },
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