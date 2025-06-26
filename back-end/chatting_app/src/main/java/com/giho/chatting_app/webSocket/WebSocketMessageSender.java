package com.giho.chatting_app.webSocket;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import com.giho.chatting_app.event.ChatMessageEvent;

import lombok.RequiredArgsConstructor;

import java.util.Map;

@Component
@RequiredArgsConstructor
public class WebSocketMessageSender {
  
  private final SimpMessagingTemplate messagingTemplate;

  public void sendFriendRequestNotification(String targetUserId, String fromUserId) {
    messagingTemplate.convertAndSend(
      "/topic/friend-request/" + targetUserId,
      fromUserId + "님이 친구 요청을 보냈습니다."
    );
  }

  public void sendFriendAcceptNotification(String targetUserId, String fromUserId) {
    messagingTemplate.convertAndSend(
      "/topic/friend-accept/" + targetUserId,
      fromUserId + "님이 친구 요청을 수락했습니다."
    );
  }

  public void sendFriendDeclineNotification(String targetUserId, String fromUserId) {
    messagingTemplate.convertAndSend(
      "/topic/friend-decline/" + targetUserId,
      fromUserId + "님이 친구 요청을 거절했습니다."
    );
  }

  public void sendMessageNotification(ChatMessageEvent event) {
    messagingTemplate.convertAndSend(
      "/topic/chat-room/" + event.roomId(),
      event
    );
  }

  public void sendReadReceipt(String roomId, String messageId, String readerId) {
    Map<String, String> payload = Map.of(
      "messageId", messageId,
      "readerId", readerId
    );
    System.out.println("read payload: " + payload);
    messagingTemplate.convertAndSend(
      "/topic/chat-room/read/" + roomId,
      payload
    );
  }
}
