package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@Builder
public class BroadcastRoomInfo {
  private String roomId;
  private String roomName;
  private String senderNickName;
  private LocalDateTime createdAt;

  // createdAt을 자동으로 생성하는 생성자 추가
  public BroadcastRoomInfo(String roomId, String roomName, String senderNickName) {
    this.roomId = roomId;
    this.roomName = roomName;
    this.senderNickName = senderNickName;
    this.createdAt = LocalDateTime.now();
  }
}
