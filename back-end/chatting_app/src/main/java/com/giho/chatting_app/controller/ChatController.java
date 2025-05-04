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

  // 클라이언트가 /app.send로 보낸 메시지 처리
  @MessageMapping("/chat.send")
  public void sendMessage(ChatMessage message) {
    chatService.sendMessage(message);
  }
}
