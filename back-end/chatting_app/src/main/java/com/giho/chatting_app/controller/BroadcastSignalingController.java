package com.giho.chatting_app.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.Map;

@Slf4j
@Controller
public class BroadcastSignalingController {

  @Autowired
  private SimpMessagingTemplate messagingTemplate;

  @MessageMapping("/broadcast/peer/offer/{roomId}")
  public void handleOffer(@Payload String offer,
                          @DestinationVariable(value = "roomId") String roomId) {
    log.info("[BROADCAST Offer] roomId={}, offer={}", roomId, offer);
    messagingTemplate.convertAndSend("/topic/broadcast/peer/offer/" + roomId, offer);
  }

  @MessageMapping("/broadcast/peer/answer/{roomId}/{viewerId}")
  public void handleAnswer(@Payload String answer,
                           @DestinationVariable(value = "roomId") String roomId,
                           @DestinationVariable(value = "viewerId") String viewerId) {
    log.info("[BROADCAST Answer] roomId={}, viewerId={}, answer={}", roomId, viewerId, answer);
    messagingTemplate.convertAndSend("/topic/broadcast/peer/answer/" + roomId + "/" + viewerId, answer);
  }

  @MessageMapping("/broadcast/peer/candidate/{roomId}")
  public void handleCandidateFromViewer(@Payload String candidate,
                                        @DestinationVariable(value = "roomId") String roomId) {
    log.info("[BROADCAST CandidateFromViewer] roomId={}, candidate={}", roomId, candidate);
    messagingTemplate.convertAndSend("/topic/broadcast/peer/candidate/" + roomId, candidate);
  }

  @MessageMapping("/broadcast/peer/candidate/viewer/{roomId}")
  public void handleCandidateToViewer(@Payload String candidate,
                                      @DestinationVariable(value = "roomId") String roomId) {
    log.info("[BROADCAST CandidateToViewer] roomId={}, candidate={}", roomId, candidate);
    messagingTemplate.convertAndSend("/topic/broadcast/peer/candidate/viewer/" + roomId, candidate);
  }

}
