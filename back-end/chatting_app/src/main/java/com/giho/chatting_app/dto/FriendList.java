package com.giho.chatting_app.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class FriendList {
  List<UserInfo> friends;
}
