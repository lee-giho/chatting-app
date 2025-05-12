package com.giho.chatting_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.service.kafka.KafkaProducerService;

@RestController
@RequestMapping("/api/friend")
public class FriendController {
  
  @Autowired
  private KafkaProducerService kafkaProducerService;

  // 친구 요청 엔드포인트
  @PostMapping("/request")
  public ResponseEntity<?> requestFriend(@RequestParam String fromUserId, @RequestParam String toUserId) {
    kafkaProducerService.sendFriendRequest(fromUserId, toUserId);
    return ResponseEntity.ok("친구 요청 보냈습니다.");
  }

  // 친구 수락 엔드포인트
  @PostMapping("/accept")
  public ResponseEntity<?> acceptFriend(@RequestParam String fromUserId, @RequestParam String toUserId) {
    kafkaProducerService.sendFriendAccept(fromUserId, toUserId);
    return ResponseEntity.ok("친구 요청을 수락했습니다.");
  }
}
