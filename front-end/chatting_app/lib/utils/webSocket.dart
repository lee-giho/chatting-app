import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class Websocket {
  late StompClient stompClient;
  final wsAddress = dotenv.get("WS_ADDRESS");

  void connectToWebSocket(String myUserId) {
    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws-chat",
        onConnect: (StompFrame frame) {
          // 친구 요청 알림 구독
          stompClient.subscribe(
            destination: "/topic/friend-request/$myUserId",
            callback: (frame) {
              final message = frame.body;
              print("친구 요청 수신: $message");
            }
          );
        },
        onWebSocketError: (error) => print("WebSocket error: $error")
      )
    );

    stompClient.activate();
  }
}