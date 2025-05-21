package com.giho.chatting_app.service.kafka;

import java.time.LocalDateTime;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.domain.ChatMessages;
import com.giho.chatting_app.domain.Friend;
import com.giho.chatting_app.domain.FriendStatus;
import com.giho.chatting_app.dto.ChatMessage;
import com.giho.chatting_app.event.ChatMessageEvent;
import com.giho.chatting_app.event.FriendAcceptedEvent;
import com.giho.chatting_app.event.FriendDeclinedEvent;
import com.giho.chatting_app.event.FriendRequestedEvent;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.ChatMessagesRepository;
import com.giho.chatting_app.repository.FriendRepository;
import com.giho.chatting_app.util.JwtProvider;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class KafkaProducerService {
  
  @Qualifier("objectKafkaTemplate")
  private final KafkaTemplate<String, Object> kafkaTemplate;

  @Autowired
  private JwtProvider jwtProvider;

  @Autowired
  private FriendRepository friendRepository;

  @Autowired
  private ChatMessagesRepository chatMessageRepository;

  public void sendFriendRequest(String token, String toUserId) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String fromUserId = jwtProvider.getUserId(tokenWithoutBearer);

    try {
      Friend friend = Friend.builder()
        .id(UUID.randomUUID().toString())
        .userId(fromUserId)
        .friendId(toUserId)
        .status(FriendStatus.REQUESTED)
        .build();
      friendRepository.save(friend);

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
      Friend friend = friendRepository.findByUserIdAndFriendId(
        toUserId,
        fromUserId
      ).orElseThrow(() -> new CustomException(ErrorCode.FRIEND_REQUEST_NOT_FOUND));

      friend.setStatus(FriendStatus.ACCEPTED);
      friendRepository.save(friend);

      kafkaTemplate.send("friend-accept", new FriendAcceptedEvent(fromUserId, toUserId)).get();
    } catch (Exception e) {
      e.printStackTrace();
      throw new CustomException(ErrorCode.INTERNAL_SERVER_ERROR);
    }
  }

  public void sendFriendDecline(String token, String toUserId) {
    
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String fromUserId = jwtProvider.getUserId(tokenWithoutBearer);

    try {
      Friend friend = friendRepository.findByUserIdAndFriendId(
        toUserId,
        fromUserId
      ).orElseThrow(() -> new CustomException(ErrorCode.FRIEND_REQUEST_NOT_FOUND));

      friendRepository.delete(friend);

      kafkaTemplate.send("friend-decline", new FriendDeclinedEvent(fromUserId, toUserId)).get();
    } catch (Exception e) {
      e.printStackTrace();
      throw new CustomException(ErrorCode.INTERNAL_SERVER_ERROR);
    }
  }

  public void sendMessage(String token, ChatMessage message) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String senderId = jwtProvider.getUserId(tokenWithoutBearer);

    try {
      ChatMessages chatMessage = ChatMessages.builder()
        .roomId(message.getRoomId())
        .sender(senderId)
        .content(message.getContent())
        .sentAt(LocalDateTime.now())
        .build();
      
      chatMessageRepository.save(chatMessage);

      ChatMessageEvent event = new ChatMessageEvent(
        chatMessage.getId(),
        chatMessage.getRoomId(),
        chatMessage.getSender(),
        chatMessage.getContent(),
        chatMessage.getSentAt()
      );
      
      kafkaTemplate.send("chat-room", event);
    } catch (Exception e) {
      e.printStackTrace();
      throw new CustomException(ErrorCode.INTERNAL_SERVER_ERROR);
    }
  }
}
