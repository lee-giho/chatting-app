package com.giho.chatting_app.service.kafka;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.event.FriendAcceptedEvent;
import com.giho.chatting_app.event.FriendRequestedEvent;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.util.JwtProvider;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KafkaProducerService {
  
  @Qualifier("objectKafkaTemplate")
  private final KafkaTemplate<String, Object> kafkaTemplate;

  @Autowired
  private JwtProvider jwtProvider;

  public void sendFriendRequest(String token, String toUserId) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String fromUserId = jwtProvider.getUserId(tokenWithoutBearer);

    try {
      kafkaTemplate.send("friend-request", new FriendRequestedEvent(fromUserId, toUserId)).get();
    } catch (Exception e) {
      e.printStackTrace();
      throw new CustomException(ErrorCode.INTERNAL_SERVER_ERROR);
    }
  }

  public void sendFriendAccept(String token, String toUserId) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String fromUserId = jwtProvider.getUserId(tokenWithoutBearer);

    try {
      kafkaTemplate.send("friend-accept", new FriendAcceptedEvent(fromUserId, toUserId)).get();
    } catch (Exception e) {
      e.printStackTrace();
      throw new CustomException(ErrorCode.INTERNAL_SERVER_ERROR);
    }
  }
}
