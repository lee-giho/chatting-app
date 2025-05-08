package com.giho.chatting_app.exception;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public class ErrorResponse {
  
  private final String code;
  private final String message;
  private final LocalDateTime timestamp;
  private final String path;
}
