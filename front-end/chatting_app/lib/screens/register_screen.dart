import 'package:flutter/material.dart';

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
                            TextFormField(
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