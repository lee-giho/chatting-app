package com.giho.chatting_app.service;

import java.time.LocalDateTime;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.giho.chatting_app.domain.ChatMessages;
import com.giho.chatting_app.dto.ChatMessage;
import com.giho.chatting_app.repository.ChatMessageRepository;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class KafkaChatListener {

  private final SimpMessagingTemplate messagingTemplate;
  private final ChatMessageRepository chatMessageRepository;
  private final ObjectMapper objectMapper = new ObjectMapper();

  @KafkaListener(
    topics = "chat-room",
    groupId = "chat-group",
    containerFactory = "stringKafkaListenerFactory"
  )
  public void listen(String message) {
    try {
      ChatMessage chatMessage = objectMapper.readValue(message, ChatMessage.class);

      // WebSocket 구독자에게 메시지 전송
      messagingTemplate.convertAndSend("/topic/room/" + chatMessage.getRoomId(), chatMessage);

      // MongoDB에 메시지 저장
      ChatMessages chatMessageDocument = ChatMessages.builder()
        .roomId(chatMessage.getRoomId())
        .sender(chatMessage.getSender())
        .content(chatMessage.getContent())
        .sentAt(LocalDateTime.now())
        .build();

      chatMessageRepository.save(chatMessageDocument);

    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
