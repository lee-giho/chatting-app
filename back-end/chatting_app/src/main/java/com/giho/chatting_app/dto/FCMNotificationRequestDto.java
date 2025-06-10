package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FCMNotificationRequestDto {
  private String targetUserId;
  private String title;
  private String body;
}
