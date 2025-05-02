package com.giho.chatting_app.service;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class ChatConsumer {
  @KafkaListener(topics = "chat-topic", groupId = "chat")
  public void listen(String message) {
    System.out.println("Received: " + message);
  }
}
