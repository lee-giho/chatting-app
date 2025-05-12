package com.giho.chatting_app.service.kafka;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.event.FriendAcceptedEvent;
import com.giho.chatting_app.event.FriendRequestedEvent;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KafkaProducerService {
  
  @Qualifier("objectKafkaTemplate")
  private final KafkaTemplate<String, Object> kafkaTemplate;

  public void sendFriendRequest(String fromUserId, String toUserId) {
    kafkaTemplate.send("friend-request", new FriendRequestedEvent(fromUserId, toUserId));
  }

  public void sendFriendAccept(String fromUserId, String toUserId) {
    kafkaTemplate.send("friend_accept", new FriendAcceptedEvent(fromUserId, toUserId));
  }
}
