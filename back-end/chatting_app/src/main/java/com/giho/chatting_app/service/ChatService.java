package com.giho.chatting_app.service;

import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.giho.chatting_app.dto.ChatMessage;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class ChatService {
  
  private final KafkaTemplate<String, String> kafkaTemplate;
  private final ObjectMapper objectMapper = new ObjectMapper();

  public void sendMessage(ChatMessage message) {
    try {
      String jsonMessage = objectMapper.writeValueAsString(message);
      kafkaTemplate.send("chat-room", jsonMessage);
    } catch (JsonProcessingException e) {
      throw new RuntimeException("메시지 직렬화 실패", e);
    }
  }
}
