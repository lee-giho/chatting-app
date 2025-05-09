package com.giho.chatting_app.dto;

import lombok.Data;

@Data
public class SignUpRequest {
  private String id;
  private String password;
  private String nickName;
}
