package com.giho.chatting_app.dto;

import com.giho.chatting_app.domain.ChatRoom;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class ChatRoomAndFriendInfo {
  private ChatRoom chatRoomInfo;
  private UserInfo friendInfo;
}
