import 'package:chatting_app/firebase_options.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");
}

Future<void> fcmSetting() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true
  );

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true
  );

  print("Permission: ${settings.authorizationStatus}");

  // foreground에서 푸시 알림 표시를 위한 알림 중요도 설정 (안드로이드)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'chatting-app',
    "chatting-app",
    description: '채팅앱 알림',
    importance: Importance.max
  );
  
  // foreground에서 푸시 알림 표시를 위한 local notifications 설정
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  // Foreground 알림 핸들링
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    print("[foreground] 알림 도착!!!");
    print("Message data: ${message.data}");

    if (message.notification != null && android != null) {
      print(">>> show() 호출 직전");
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'ic_launcher'
          )
        )
      );
      print(">>> show() 호출 직후");

      print("메세지에 포함된 알림: ${message.notification}");
    } else {
      print(">>> notification 또는 android 페이로드가 null이라 알림 표시 안 함");
    }
  });

  // FCM 토큰 발급 및 저장
  String? fcmToken = await messaging.getToken();
  print('firebaseToken: $fcmToken');
  await SecureStorage.saveFcmToken(fcmToken!);
}