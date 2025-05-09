import 'dart:developer';

import 'package:chatting_app/utils/secureStorage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Tokenservice {

  // token 유효성 검사
  Future<bool> validateToken(String token) async {

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/token/validation");
    final headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data["bool"];
      } else {
        return false;
      }
    } catch (e) {
      log("네트워크 오류: ${e.toString()}");
      return false;
    }
  }

  // refreshToken으로 새로운 accessToken 발급
  Future<bool> refreshAccessToken(String refreshToken) async {

    // .env에서 서버 주소 가져오기
    final apiAddress = Uri.parse("${dotenv.get("API_ADDRESS")}/api/token/reissuance");
    final headers = {'Authorization': 'Bearer $refreshToken'};

    try {
      final response = await http.post(
        apiAddress,
        headers: headers
      );

      log("response data = ${utf8.decode(response.bodyBytes)}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // 새로운 accessToken을 받아오고 SecureStorage에 저장
        String newAccessToken = data["accessToken"];
        await SecureStorage.saveAccessToken(newAccessToken);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      log("네트워크 오류: ${e.toString()}");
      return false;
    }
  }
}