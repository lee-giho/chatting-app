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
      // 객체를 JSON 문자열로 변환
      String jsonMessage = objectMapper.writeValueAsString(message);
      kafkaTemplate.send("chat-room", jsonMessage); // Kafka에 전송
    } catch (JsonProcessingException e) {
      throw new RuntimeException("메시지 직렬화 실패", e);
    }
  }
}
