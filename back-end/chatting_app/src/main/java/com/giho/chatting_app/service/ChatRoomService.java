package com.giho.chatting_app.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.giho.chatting_app.dto.ChatRoom;

@Service
public class ChatRoomService {
  
  private final Map<String, ChatRoom> chatRooms = new LinkedHashMap<>();

  public ChatRoom createRoom(String name) {
    String roomId = UUID.randomUUID().toString();
    ChatRoom chatRoom = new ChatRoom(roomId, name);
    chatRooms.put(roomId, chatRoom);
    return chatRoom;
  }

  public List<ChatRoom> getAllRooms() {
    return new ArrayList<>(chatRooms.values());
  }

  public ChatRoom findRoomById(String roomId) {
    return chatRooms.get(roomId);
  }
}
