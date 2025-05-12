package com.giho.chatting_app.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.domain.Friend;
import com.giho.chatting_app.service.FriendService;
import com.giho.chatting_app.service.kafka.KafkaProducerService;

@RestController
@RequestMapping("/api/friend")
public class FriendController {
  
  @Autowired
  private KafkaProducerService kafkaProducerService;

  @Autowired
  private FriendService friendService;

  // 친구 요청 엔드포인트
  @PostMapping("/request")
  public ResponseEntity<?> requestFriend(@RequestHeader("Authorization") String token, @RequestParam("toUserId") String toUserId) {
    kafkaProducerService.sendFriendRequest(token, toUserId);
    return ResponseEntity.ok("친구 요청 보냈습니다.");
  }

  // 친구 수락 엔드포인트
  @PostMapping("/accept")
  public ResponseEntity<?> acceptFriend(@RequestHeader("Authorization") String token, @RequestParam("toUserId") String toUserId) {
    kafkaProducerService.sendFriendAccept(token, toUserId);
    return ResponseEntity.ok("친구 요청을 수락했습니다.");
  }

  // 친구 요청 목록 조회 엔드포인트
  @GetMapping("requests")
  public ResponseEntity<List<Friend>> getReceivedFriendRequests(@RequestParam("userId") String userId) {
    List<Friend> requests = friendService.getReceivedFriendRequests(userId);
    return ResponseEntity.ok(requests);
  }
}
