package com.giho.chatting_app.controller;

import com.giho.chatting_app.dto.SignalMessage;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class SignalingController {

  // offer
  @MessageMapping("/offer")
  @SendTo("/topic/offer")
  public SignalMessage handleOffer(SignalMessage message) {
    return message;
  }

  // answer
  @MessageMapping("/answer")
  @SendTo("/topic/answer")
  public SignalMessage handleAnswer(SignalMessage message) {
    return message;
  }

  // ICE
  @MessageMapping("/ice")
  @SendTo("/topic/ice")
  public SignalMessage handleIce(SignalMessage message) {
    return message;
  }
}
