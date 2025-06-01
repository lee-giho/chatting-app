package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class CreateBroadcastRoomRequest {
  private String roomId;
  private String roomName;
}
