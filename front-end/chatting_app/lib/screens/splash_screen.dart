import 'package:chatting_app/screens/home_screen.dart';
import 'package:chatting_app/screens/login_screen.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/utils/tokenService.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  // 자동 로그인 확인
  Future<void> checkLogin() async {

    bool? isAutoLogin = await SecureStorage.getIsAutoLogin() ?? false;
    String? accessToken = await SecureStorage.getAccessToken();
    String? refreshToken = await SecureStorage.getRefreshToken();

    print("isAutoLogin: $isAutoLogin");
    print("accessToken: $accessToken");
    print("refreshToken: $refreshToken");

    // 자동 로그인이 true일 경우
    if (isAutoLogin) {
      if (accessToken != null && refreshToken != null) { // 토큰이 있으면 유효성 검사 후 로그인 처리
        bool isValid = await Tokenservice().validateToken(accessToken);

        if (isValid) { // 토큰이 유효하면
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomeScreen()
            )
          );
        } else { // accessToken이 만료되었으면 refreshToken으로 새로운 accessToken 발급
          bool isRefreshed = await Tokenservice().refreshAccessToken(refreshToken);
          if (isRefreshed) { // accessToken이 새로 발급 됐을 때
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen()
              )
            );
          } else { // refreshToken도 만료되었을 때
            await SecureStorage.deleteTokensAndAutoLogin(); // 토큰과 자동 로그인 값 초기화
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen()
              )
            );
          }
        }
      } else { // 토큰이 없을 때
        await SecureStorage.saveIsAutoLogin(false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen()
          )
        );
      }
    } else { // 자동 로그인이 아닐 때
      await SecureStorage.deleteTokensAndAutoLogin();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen()
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // 로딩중 표시
      ),
    );
  }
}