package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class UserInfo {
  private String id;
  private String nickName;
  private String profileImage;
}
