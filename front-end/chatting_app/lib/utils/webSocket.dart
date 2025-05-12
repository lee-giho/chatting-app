import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class WebSocket {

  static final WebSocket instance = WebSocket.internal();
  factory WebSocket() => instance;
  WebSocket.internal();

  final List<void Function(String)> friendRequestListeners = [];

  bool isConnected = false;

  late StompClient stompClient;
  final wsAddress = dotenv.get("WS_ADDRESS");

  void connectToWebSocket(String myUserId) {
    if (isConnected) return;

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws-chat",
        onConnect: (StompFrame frame) {
          // 친구 요청 알림 구독
          stompClient.subscribe(
            destination: "/topic/friend-request/$myUserId",
            callback: (frame) {
              final message = frame.body ?? "";
              print("친구 요청 수신: $message");
              for (final listener in friendRequestListeners) {
                listener(message);
              }
            }
          );
        },
        onWebSocketError: (error) => print("WebSocket error: $error")
      )
    );

    stompClient.activate();
  }

  // 콜백 등록
  void addFriendRequestListener(void Function(String message) callback) {
    friendRequestListeners.add(callback);
  }

  // 콜백 해제
  void removeFriendRequestListener(void Function(String message) callback) {
    friendRequestListeners.remove(callback);
  }
}