package com.giho.chatting_app.controller;

import java.util.List;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.ChatRoom;
import com.giho.chatting_app.service.ChatRoomService;

import lombok.AllArgsConstructor;

@RestController
@RequestMapping("/api/rooms")
@AllArgsConstructor
public class ChatRoomController {
  
  private final ChatRoomService chatRoomService;

  @PostMapping
  public ChatRoom createRoom(@RequestParam("name") String name) {
    return chatRoomService.createRoom(name);
  }

  @GetMapping
  public List<ChatRoom> getRoomList() {
    return chatRoomService.getAllRooms();
  }

  @GetMapping("/{roomId}")
  public ChatRoom getRoom(@PathVariable String roomId) {
    return chatRoomService.findRoomById(roomId);
  }
}
