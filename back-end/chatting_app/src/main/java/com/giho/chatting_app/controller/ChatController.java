package com.giho.chatting_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.ChatMessage;
import com.giho.chatting_app.service.kafka.KafkaProducerService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class ChatController {

  @Autowired
  private KafkaProducerService kafkaProducerService;

  @MessageMapping("/chat.send")
  public void sendMessage(@Header("Authorization") String token, ChatMessage message) {
    kafkaProducerService.sendMessage(token, message);
  }
}
