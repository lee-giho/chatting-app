package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

import java.util.List;

@Data
@AllArgsConstructor
public class BroadcastRoomList {
  private List<BroadcastRoomInfo> broadcastRoomInfoList;
}
