package com.giho.chatting_app.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.ChatMessage;
import com.giho.chatting_app.service.ChatService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
public class ChatController {
  
  private final ChatService chatService;

  @MessageMapping("/chat.send")
  public void sendMessage(ChatMessage message) {
    chatService.sendMessage(message);
  }
}
