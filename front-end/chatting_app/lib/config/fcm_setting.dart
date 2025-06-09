import 'package:chatting_app/firebase_options.dart';
import 'package:chatting_app/utils/secureStorage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling background message: ${msg.messageId}");
}

Future<void> fcmSetting() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // ios 권한 요청
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true
  );
  print("Permission: ${settings.authorizationStatus}");

  // 안드로이드 Foreground 채널 설정
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'chatting-app',
    "채팅앱 알림",
    description: '채팅앱 알림',
    importance: Importance.max
  );
  final flnp = FlutterLocalNotificationsPlugin();
  await flnp.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.createNotificationChannel(channel);

  // Foreground 알림 핸들링
  FirebaseMessaging.onMessage.listen((msg) {
    final notif = msg.notification;
    final android = msg.notification?.android;
    if (notif != null && android != null) {
      flnp.show(
        notif.hashCode,
        notif.title,
        notif.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon
          )
        )
      );
    }
  });

  // FCM 토큰 발급 및 저장
  String? fcmToken = await messaging.getToken();
  print('firebaseToken: $fcmToken');
  await SecureStorage.saveFcmToken(fcmToken!);
}