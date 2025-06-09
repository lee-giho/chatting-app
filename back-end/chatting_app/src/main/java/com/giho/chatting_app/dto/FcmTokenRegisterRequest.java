package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class FcmTokenRegisterRequest {
  private String fcmToken;
  private String deviceType;
  private String deviceInfo;
}
