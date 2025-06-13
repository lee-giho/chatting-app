import 'dart:developer';

import 'package:chatting_app/screens/main_screen.dart';
import 'package:chatting_app/screens/login_screen.dart';
import 'package:chatting_app/utils/deviceInfo.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:chatting_app/utils/tokenService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  Future<bool> registerFcmToken(String accessToken) async {
    String? fcmToken = await SecureStorage.getFcmToken();
    Map<String, String> deviceInfo = await Deviceinfo().getDeviceInfo();

    // 아이폰은 알림을 사용하지 못해서 그냥 넘김
    if (deviceInfo["deviceType"] != "android") {
      return true;
    }

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/fcmToken");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };

    try {
      final response = await http.post(
        apiAddress,
        headers: headers,
        body: json.encode({
          "fcmToken": fcmToken,
          "deviceType": deviceInfo["deviceType"],
          "deviceInfo": deviceInfo["deviceInfo"]
        })
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("registerFcmToken response data: $data");
        return true;
      } else {
        log(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("FCM token 저장 실패"))
        );

        return false;
      }
    } catch (e) {
      // 예외 처리
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("네트워크 오류: ${e.toString()}"))
      );

      return false;
    }
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
          bool isFcmTokenSaved = await registerFcmToken(accessToken);

          if (isFcmTokenSaved) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainScreen()
              )
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("FCM token 저장 실패"))
            );
          }
        } else { // accessToken이 만료되었으면 refreshToken으로 새로운 accessToken 발급
          bool isRefreshed = await Tokenservice().refreshAccessToken(refreshToken);
          if (isRefreshed) { // accessToken이 새로 발급 됐을 때
            bool isFcmTokenSaved = await registerFcmToken(accessToken);

            if (isFcmTokenSaved) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainScreen()
                )
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("FCM token 저장 실패"))
              );
            }
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