package com.giho.chatting_app.controller;

import com.giho.chatting_app.dto.SignalMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Slf4j
@Controller
public class SignalingController {

  @MessageMapping("/peer/offer/{camKey}/{roomId}")
  @SendTo("/topic/peer/offer/{camKey}/{roomId}")
  public String peerHandleOffer(@Payload String offer,
                                @DestinationVariable(value = "roomId") String roomId,
                                @DestinationVariable(value = "camKey") String camKey) {
    log.info("[OFFER] {} : {}", camKey, offer);
    return offer;
  }

  @MessageMapping("/peer/iceCandidate/{camKey}/{roomId}")
  @SendTo("/topic/peer/iceCandidate/{camKey}/{roomId}")
  public String peerHandleIceCandidate(@Payload String candidate,
                                       @DestinationVariable(value = "roomId") String roomId,
                                       @DestinationVariable(value = "camKey") String camKey) {
    log.info("[ICECANDIDATE] {} : {}", camKey, candidate);
    return candidate;
  }

  @MessageMapping("/peer/answer/{camKey}/{roomId}")
  @SendTo("/topic/peer/answer/{camKey}/{roomId}")
  public String peerHandleAnswer(@Payload String answer,
                                 @DestinationVariable(value = "roomId") String roomId,
                                 @DestinationVariable(value = "camKey") String camKey) {
    log.info("[ANSWER] {} : {}", camKey, answer);
    return answer;
  }

  @MessageMapping("/call/key")
  @SendTo("/topic/call/key")
  public String callKey(@Payload String message) {
    log.info("[Key] : {}", message);
    return message;
  }

  @MessageMapping("/send/key")
  @SendTo("/topic/send/key")
  public String sendKey(@Payload String message) {
    return message;
  }
}