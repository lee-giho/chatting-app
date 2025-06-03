import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';

class WebSocket {

  static final WebSocket instance = WebSocket.internal();
  factory WebSocket() => instance;
  WebSocket.internal();

  final List<void Function(String)> showMessageListeners = [];
  final List<void Function()> voidFunctionListeners = [];
  final List<void Function(String)> friendRequestListeners = [];
  final List<void Function(String)> friendAcceptListeners = [];
  final List<void Function(String)> friendDeclineListeners = [];

  bool isConnected = false;

  late StompClient stompClient;
  final wsAddress = dotenv.get("WS_ADDRESS");

  void connect(String myUserId) {
    if (isConnected) return;

    stompClient = StompClient(
      config: StompConfig(
        url: "$wsAddress/ws-chat",
        onConnect: (StompFrame frame) {
          isConnected = true;

          // 친구 요청 알림 구독
          stompClient.subscribe(
            destination: "/topic/friend-request/$myUserId",
            callback: (frame) {
              final message = frame.body ?? "";
              print("친구 요청 수신: $message");
              for (var listener in friendRequestListeners) {
                listener(message);
              }
              for (var listener in showMessageListeners) {
                listener(message);
              }
              for (var listener in voidFunctionListeners) {
                listener();
              }
            }
          );

          // 친구 수락 알림 구독
          stompClient.subscribe(
            destination: "/topic/friend-accept/$myUserId",
            callback: (frame) {
              final message = frame.body ?? "";
              print("친구 수락 수신: $message");
              for (var listener in friendAcceptListeners) {
                listener(message);
              }
              for (var listener in showMessageListeners) {
                listener(message);
              }
              for (var listener in voidFunctionListeners) {
                listener();
              }
            }
          );

          // 친구 거절 알림 구독
          stompClient.subscribe(
            destination: "/topic/friend-decline/$myUserId",
            callback: (frame) {
              final message = frame.body ?? "";
              print("친구 거절 수신: $message");
              for (var listener in friendDeclineListeners) {
                listener(message);
              }
              for (var listener in showMessageListeners) {
                listener(message);
              }
              for (var listener in voidFunctionListeners) {
                listener();
              }
            }
          );

        },
        onWebSocketError: (error) => print("WebSocket error: $error")
      )
    );

    stompClient.activate();
  }

  // 메시지 보여주는 요청 콜백 등록
  void addShowMessageListener(void Function(String message) callback) {
    showMessageListeners.add(callback);
  }

  // 메시지 보여주는 요청 콜백 해제
  void removeShowMessageListener(void Function(String message) callback) {
    showMessageListeners.remove(callback);
  }

  // void를 갖는 함수 콜백 등록
  void addVoidFunctionListener(void Function() callback) {
    voidFunctionListeners.add(callback);
  }

  // void를 갖는 함수 콜백 해제
  void removeVoidFunctionListener(void Function() callback) {
    voidFunctionListeners.remove(callback);
  }

  // 친구 요청 콜백 등록
  void addFriendRequestListener(void Function(String message) callback) {
    friendRequestListeners.add(callback);
  }

  // 친구 요청 콜백 해제
  void removeFriendRequestListener(void Function(String message) callback) {
    friendRequestListeners.remove(callback);
  }

  // 친구 수락 콜백 등록
  void addFriendAcceptListener(void Function(String message) callback) {
    friendAcceptListeners.add(callback);
  }

  // 친구 수락 콜백 해제
  void removeFriendAcceptListener(void Function(String message) callback) {
    friendAcceptListeners.remove(callback);
  }

  // 친구 거절 콜백 등록
  void addFriendDeclineListener(void Function(String message) callback) {
    friendDeclineListeners.add(callback);
  }

  // 친구 거절 콜백 해제
  void removeFriendDeclineListener(void Function(String message) callback) {
    friendDeclineListeners.remove(callback);
  }
}