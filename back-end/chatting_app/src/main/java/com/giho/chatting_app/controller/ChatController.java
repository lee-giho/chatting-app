package com.giho.chatting_app.controller;

import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.service.ChatProducer;

import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;


@RestController
@RequiredArgsConstructor
public class ChatController {
  private final ChatProducer chatProducer;

  @PostMapping("/send")
  public String sendMessage(@RequestParam("message") String message) {
    chatProducer.sendMessage(message);
    return "Message sent: " + message;
  }
}
