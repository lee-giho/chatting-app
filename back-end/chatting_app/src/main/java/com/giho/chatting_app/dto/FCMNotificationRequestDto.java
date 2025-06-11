package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class FCMNotificationRequestDto {
  private String targetUserId;
  private String title;
  private String body;
}
