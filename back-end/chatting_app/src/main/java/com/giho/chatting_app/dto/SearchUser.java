package com.giho.chatting_app.dto;

import com.giho.chatting_app.entity.Friend;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class SearchUser {
  private UserInfo userInfo;
  private Friend friend;
}
