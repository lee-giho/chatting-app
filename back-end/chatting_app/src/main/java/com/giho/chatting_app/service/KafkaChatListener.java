package com.giho.chatting_app.service;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.giho.chatting_app.dto.ChatMessage;

import lombok.RequiredArgsConstructor;

@Component
@RequiredArgsConstructor
public class KafkaChatListener {

  private final SimpMessagingTemplate messagingTemplate;
  private final ObjectMapper objectMapper = new ObjectMapper();

  @KafkaListener(topics = "chat-room", groupId = "chat-group")
  public void listen(String message) {
    try {
      ChatMessage chatMessage = objectMapper.readValue(message, ChatMessage.class);
      messagingTemplate.convertAndSend("/topic/room/" + chatMessage.getRoomId(), chatMessage);
    } catch (Exception e) {
      e.printStackTrace();
    }
  }
}
