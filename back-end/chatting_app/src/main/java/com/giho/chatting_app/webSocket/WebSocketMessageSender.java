package com.giho.chatting_app.webSocket;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import lombok.RequiredArgsConstructor;

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
}
