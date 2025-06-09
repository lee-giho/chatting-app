import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  
  // FlutterSecureStorage 인스턴스 생성
  static final storage = FlutterSecureStorage();

  // write 메서드
  static Future<void> writeData(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  // read 메서드
  static Future<String?> readData(String key) async{
    return await storage.read(key: key);
  }

  // autoLogin 저장
  static Future<void> saveIsAutoLogin(bool? isAutoLogin) async {
    await storage.write(
      key: "autoLogin",
      value: isAutoLogin.toString() // bool -> String 변환
    );
  }

  // autoLogin 읽기
  static Future<bool?> getIsAutoLogin() async {
    final isAutoLogin = await storage.read(key: "autoLogin");
    if (isAutoLogin == null) {
      return null;
    }
    return isAutoLogin.toLowerCase() == "true"; // String -> bool 변환
  }

  // accessToken 저장
  static Future<void> saveAccessToken(String accessToken) async {
    await storage.write(
      key: "accessToken",
      value: accessToken
    );
  }

  // accessToken 읽기
  static Future<String?> getAccessToken() async {
    return await storage.read(key: "accessToken");
  }

  // refreshToken 저장
  static Future<void> saveRefreshToken(String refreshToken) async {
    await storage.write(
      key: "refreshToken",
      value: refreshToken
    );
  }

  // refreshToken 읽기
  static Future<String?> getRefreshToken() async {
    return await storage.read(key: "refreshToken");
  }

  // FCM token 저장
  static Future<void> saveFcmToken(String fcmToken) async {
    await storage.write(
      key: "fcmToken",
      value: fcmToken
    );
  }

  // FCM token 읽기
  static Future<String?> getFcmToken() async {
    return await storage.read(key: "fcmToken");
  }

  // 토큰 & 자동 로그인 삭제 (로그아웃 시)
  static Future<void> deleteTokensAndAutoLogin() async {
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");
    await saveIsAutoLogin(false);
  }
}