package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class BroadcastRoomInfo {
  private String roomId;
  private String roomName;
  private String senderNickName;
}
