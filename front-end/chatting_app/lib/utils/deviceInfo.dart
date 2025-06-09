import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class Deviceinfo {
  Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        "deviceType": "android",
        "deviceInfo": "${androidInfo.manufacturer} ${androidInfo.model}"
      };
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        "deviceType": "ios",
        "deviceInfo": "${iosInfo.utsname.machine} (${iosInfo.name})"
      };
    } else {
      return {
        "deviceType": "unknown",
        "deviceInfo": "unknown device"
      };
    }
  }
}