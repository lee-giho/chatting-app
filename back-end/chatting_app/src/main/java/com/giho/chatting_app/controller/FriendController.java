package com.giho.chatting_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.CountResponse;
import com.giho.chatting_app.dto.FriendList;
import com.giho.chatting_app.dto.ReceivedFriendListResponse;
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

  // 친구 거절 엔드포인트
  @DeleteMapping("/decline")
  public ResponseEntity<?> declineFriend(@RequestHeader("Authorization") String token, @RequestParam("toUserId") String toUserId) {
    kafkaProducerService.sendFriendDecline(token, toUserId);
    return ResponseEntity.ok("친구 요청을 거절했습니다.");
  }

  // 친구 요청 목록 조회 엔드포인트
  @GetMapping("/requests")
  public ResponseEntity<ReceivedFriendListResponse> getReceivedFriendRequests(@RequestHeader("Authorization") String token) {
    ReceivedFriendListResponse receivedFriendListResponse = friendService.getReceivedFriendRequests(token);
    return ResponseEntity.ok(receivedFriendListResponse);
  }

  // 친구 수 요청 엔트포인트
  @GetMapping("/count")
  public ResponseEntity<CountResponse> getRequestFriendCount(@RequestHeader("Authorization") String token) {
    CountResponse countResponse = friendService.getRequestFriendCount(token);
    return ResponseEntity.ok(countResponse);
  }

  // 친구 목록 반환 엔드포인트
  @GetMapping("/list")
  public ResponseEntity<FriendList> getFriendList(@RequestHeader("Authorization") String token) {
    FriendList friendList = friendService.getFriendList(token);
    return ResponseEntity.ok(friendList);
  }

  // 친구 삭제 엔드포인트
  @DeleteMapping
  public ResponseEntity<BooleanResponse> deleteFriend(@RequestHeader("Authorization") String token, @RequestParam("friendId") String friendId) {
    BooleanResponse booleanResponse = friendService.deleteFriend(token, friendId);
    return ResponseEntity.ok(booleanResponse);
  }
}
