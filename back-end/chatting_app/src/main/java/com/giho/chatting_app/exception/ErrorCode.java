package com.giho.chatting_app.exception;

import org.springframework.http.HttpStatus;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public enum ErrorCode {

  // 사용자
  USER_NOT_FOUND(HttpStatus.NOT_FOUND, "해당 사용자를 찾을 수 없습니다."),
  INVALID_PASSWORD(HttpStatus.UNAUTHORIZED, "비밀번호가 일치하지 않습니다."),
  DUPLICATE_USER_ID(HttpStatus.CONFLICT, "이미 사용 중인 아이디입니다."),
  DUPLICATE_NICKNAME(HttpStatus.CONFLICT, "이미 사용 중인 닉네임입니다."),

  // 친구
  FRIEND_REQUEST_NOT_FOUND(HttpStatus.NOT_FOUND, "친구 요청을 찾을 수 없습니다."),
  FRIEND_NOT_FOUND(HttpStatus.NOT_FOUND, "친구를 찾을 수 없습니다."),

  // 채팅방
  CHATROOM_NOT_FOUND(HttpStatus.NOT_FOUND, "채팅방을 찾을 수 없습니다."),

  // 인증/인가 관련
  INVALID_REFRESH_TOKEN(HttpStatus.UNAUTHORIZED, "유효하지 않은 Refresh Token입니다."),
  INVALID_TOKEN_SIGNATURE(HttpStatus.UNAUTHORIZED, "잘못된 비밀키입니다."),
  TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "토큰이 만료되었습니다."),
  MALFORMED_JWT(HttpStatus.BAD_REQUEST, "유효하지 않은 JWT입니다."),
  UNSUPPORTED_JWT(HttpStatus.BAD_REQUEST, "지원되지 않는 JWT 형식입니다."),

  // 파일 처리
  FILE_NOT_FOUND(HttpStatus.NOT_FOUND, "파일을 찾을 수 없습니다."),
  FILE_STORAGE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "파일 저장 중 오류가 발생했습니다."),
  FILE_DELETE_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "파일 삭제 중 오류가 발생했습니다."),

  // 일반
  BAD_REQUEST(HttpStatus.BAD_REQUEST, "잘못된 요청입니다."),
  INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "서버 내부 오류가 발생했습니다.");

  private final HttpStatus status;
  private final String message;
}
