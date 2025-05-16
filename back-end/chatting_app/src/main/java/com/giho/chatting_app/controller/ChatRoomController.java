package com.giho.chatting_app.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.ChatRoom;
import com.giho.chatting_app.dto.ChatRoomIdResponse;
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

  // // 전체 채팅방 목록 반환
  // @GetMapping
  // public List<ChatRoom> getRoomList() {
  //   return chatRoomService.getAllRooms();
  // }

  // // 특정 채팅방 반환
  // @GetMapping("/{roomId}")
  // public ChatRoom getRoom(@PathVariable String roomId) {
  //   return chatRoomService.findRoomById(roomId);
  // }
}
