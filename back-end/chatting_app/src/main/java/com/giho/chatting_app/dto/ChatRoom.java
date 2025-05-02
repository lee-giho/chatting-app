package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ChatRoom {
  private String roomId;
  private String name;
}
