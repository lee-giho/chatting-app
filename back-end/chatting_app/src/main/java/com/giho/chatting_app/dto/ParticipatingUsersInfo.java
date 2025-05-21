package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class ParticipatingUsersInfo {
  private UserInfo myInfo;
  private UserInfo friendInfo;
  private String creatorId;
}
