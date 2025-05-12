package com.giho.chatting_app.service.kafka;

import java.util.UUID;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.domain.Friend;
import com.giho.chatting_app.domain.FriendStatus;
import com.giho.chatting_app.event.FriendAcceptedEvent;
import com.giho.chatting_app.event.FriendRequestedEvent;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.FriendRepository;
import com.giho.chatting_app.webSocket.WebSocketMessageSender;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KafkaConsumerService {
  
  private final FriendRepository friendRepository;
  private final WebSocketMessageSender messageSender;

  // 친구 요청 이벤트 처리
  @KafkaListener(
    topics = "friend-request",
    groupId = "friend-service",
    containerFactory = "objectKafkaListenerFactory"
  )
  public void handleFriendRequest(FriendRequestedEvent event) {
    Friend friend = Friend.builder()
      .id(UUID.randomUUID().toString())
      .userId(event.requesterId())
      .friendId(event.targetId())
      .status(FriendStatus.REQUESTED)
      .build();
    friendRepository.save(friend);

    // 친구 요청 수신자에게 WebSocket 알림 전송
    messageSender.sendFriendRequestNotification(event.targetId(), event.requesterId());
  }

  // 친구 수락 이벤트 처리
  @KafkaListener(topics = "friend-accept", groupId = "friend-service")
  public void handleFriendAccept(FriendAcceptedEvent event) {
    Friend friend = friendRepository.findByUserIdAndFriendId(
      event.requesterId(),
      event.targetId()
    ).orElseThrow(() -> new CustomException(ErrorCode.FRIEND_REQUEST_NOT_FOUND));

    friend.setStatus(FriendStatus.ACCEPTED);
    friendRepository.save(friend);
  }
}
