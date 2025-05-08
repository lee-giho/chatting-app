package com.giho.chatting_app.exception;

import org.springframework.http.HttpStatus;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public enum ErrorCode {

  // 인증/인가 관련
  INVALID_TOKEN_SIGNATURE(HttpStatus.UNAUTHORIZED, "잘못된 비밀키입니다."),
  TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "토큰이 만료되었습니다."),
  MALFORMED_JWT(HttpStatus.BAD_REQUEST, "유효하지 않은 JWT입니다."),
  UNSUPPORTED_JWT(HttpStatus.BAD_REQUEST, "지원되지 않는 JWT 형식입니다."),

  // 일반
  BAD_REQUEST(HttpStatus.BAD_REQUEST, "잘못된 요청입니다."),
  INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생했습니다.");

  private final HttpStatus status;
  private final String message;
}
