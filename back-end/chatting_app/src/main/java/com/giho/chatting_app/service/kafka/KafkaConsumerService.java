package com.giho.chatting_app.service.kafka;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.event.FriendAcceptedEvent;
import com.giho.chatting_app.event.FriendDeclinedEvent;
import com.giho.chatting_app.event.FriendRequestedEvent;
import com.giho.chatting_app.webSocket.WebSocketMessageSender;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KafkaConsumerService {
  
  private final WebSocketMessageSender messageSender;

  // 친구 요청 이벤트 처리
  @KafkaListener(
    topics = "friend-request",
    groupId = "friend-service",
    containerFactory = "objectKafkaListenerFactory"
  )
  public void handleFriendRequest(FriendRequestedEvent event) {

    // 친구 요청 수신자에게 WebSocket 알림 전송
    messageSender.sendFriendRequestNotification(event.targetId(), event.requesterId());
  }

  // 친구 수락 이벤트 처리
  @KafkaListener(
    topics = "friend-accept",
    groupId = "friend-service",
    containerFactory = "objectKafkaListenerFactory"
  )
  public void handleFriendAccept(FriendAcceptedEvent event) {

    // 친구 수락 수진자에게 WebSocket 알림 전송
    messageSender.sendFriendAcceptNotification(event.targetId(), event.requesterId());
  }

  // 친구 거절 이벹느 처리
  @KafkaListener(
    topics = "friend-decline",
    groupId = "friend-service",
    containerFactory = "objectKafkaListenerFactory"
  )
  public void handleFriendDecline(FriendDeclinedEvent event) {
    
    // 친구 거절 수신자에게 WebSocket 알림 전송
    messageSender.sendFriendDeclineNotification(event.targetId(), event.requesterId());
  }
}
