package com.giho.chatting_app.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.ChatRoomAndUserInfoList;
import com.giho.chatting_app.dto.ChatRoomIdResponse;
import com.giho.chatting_app.dto.ParticipatingUsersInfo;
import com.giho.chatting_app.service.ChatRoomService;

import lombok.AllArgsConstructor;

@RestController
@RequestMapping("/api/chatRoom")
@AllArgsConstructor
public class ChatRoomController {
  
  private final ChatRoomService chatRoomService;

  // 채팅방 생성
  @PostMapping
  public ResponseEntity<ChatRoomIdResponse> createRoom(@RequestHeader("Authorization") String token, @RequestParam("friendId") String friendId) {
    ChatRoomIdResponse chatRoomIdResponse =  chatRoomService.getChatRoomId(token, friendId);
    return ResponseEntity.ok(chatRoomIdResponse);
  }

  // 전체 채팅방 목록 반환
  @GetMapping
  public ResponseEntity<ChatRoomAndUserInfoList> getRoomList(@RequestHeader("Authorization") String token) {
    ChatRoomAndUserInfoList chatRoomAndUserInfoList = chatRoomService.getAllRooms(token);
    System.out.println(chatRoomAndUserInfoList);
    return ResponseEntity.ok(chatRoomAndUserInfoList);
  }

  // 채팅방에 있는 사용자 정보 반환 엔드포인트
  @GetMapping("/usersInfo")
  public ResponseEntity<ParticipatingUsersInfo> getParticipatingUsersInfo(@RequestHeader("Authorization") String token, @RequestParam("chatRoomId") String chatRoomId) {
    ParticipatingUsersInfo participatingUsersInfo = chatRoomService.getParticipatingUsersInfo(token, chatRoomId);
    return ResponseEntity.ok(participatingUsersInfo);
  }

  // 채팅방 삭제 엔드포인트
  @DeleteMapping
  public ResponseEntity<BooleanResponse> deleteChatRoom(@RequestHeader("Authorization") String token, @RequestParam("chatRoomId") String chatRoomId) {
    BooleanResponse booleanResponse = chatRoomService.deleteChatRoom(chatRoomId);
    return ResponseEntity.ok(booleanResponse);
  }

  // // 특정 채팅방 반환
  // @GetMapping("/{roomId}")
  // public ChatRoom getRoom(@PathVariable String roomId) {
  //   return chatRoomService.findRoomById(roomId);
  // }
}
