import 'package:chatting_app/config/fcm_setting.dart';
import 'package:chatting_app/screens/splash_screen.dart';
import 'package:chatting_app/utils/deviceInfo.dart';
import 'package:chatting_app/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, String> deviceInfo = await Deviceinfo().getDeviceInfo();
  if (deviceInfo["deviceType"] == "android") {
    await fcmSetting();
  }
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    ScreenSize().init(width: size.width, height: size.height);
    
    return LayoutBuilder(builder: (context, constraints) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Login',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, // 기본 배경색을 흰색으로 설정
          colorScheme: ColorScheme.light(), // 기본 컬러 스킴을 밝은 모드로 설정
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
      );
    });
  }
}
