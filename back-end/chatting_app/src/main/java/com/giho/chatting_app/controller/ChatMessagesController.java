package com.giho.chatting_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.web.bind.annotation.*;

import com.giho.chatting_app.entity.ChatMessages;
import com.giho.chatting_app.dto.ChatMessage;
import com.giho.chatting_app.dto.ChatMessageList;
import com.giho.chatting_app.service.ChatMessagesService;
import com.giho.chatting_app.service.kafka.KafkaProducerService;

import lombok.RequiredArgsConstructor;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chatMessage")
public class ChatMessagesController {

  @Autowired
  private KafkaProducerService kafkaProducerService;

  @Autowired
  private ChatMessagesService chatMessagesService;

  @MessageMapping("/chat.send")
  public void sendMessage(@Header("Authorization") String token, ChatMessage message) {
    kafkaProducerService.sendMessage(token, message);
  }

  @GetMapping("/all")
  public ResponseEntity<ChatMessageList> getChatMessageList(@RequestHeader("Authorization") String token, @RequestParam("chatRoomId") String chatRoomId) {
    ChatMessageList chatMessageList = chatMessagesService.getChatMessageList(chatRoomId);
    return ResponseEntity.ok(chatMessageList);
  }

  @GetMapping("/last")
  public ResponseEntity<ChatMessages> getLastChatMessage(@RequestHeader("Authorization") String token, @RequestParam("chatRoomId") String chatRoomId) {
    ChatMessages chatMessages = chatMessagesService.getLastChatMessages(chatRoomId);
    return ResponseEntity.ok(chatMessages);
  }

  @PostMapping("/read")
  public ResponseEntity<Void> markAsRead(@RequestHeader("Authorization") String token, @RequestParam("messageId") String messageId) {
    chatMessagesService.markMessageAsRead(token, messageId);
    return ResponseEntity.ok().build();
  }
}
