package com.giho.chatting_app.exception;

import java.time.LocalDateTime;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import jakarta.servlet.http.HttpServletRequest;

@RestControllerAdvice
public class GlobalExceptionHandler {
  
  @ExceptionHandler(CustomException.class)
  public ResponseEntity<ErrorResponse> handleCustomException(CustomException e, HttpServletRequest request) {
    ErrorCode errorCode = e.getErrorCode();
    ErrorResponse response = new ErrorResponse(
      errorCode.name(),
      errorCode.getMessage(),
      LocalDateTime.now(),
      request.getRequestURI()
    );
    return ResponseEntity.status(errorCode.getStatus()).body(response);
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<ErrorResponse> handleUnhandledException(Exception e, HttpServletRequest request) {
    ErrorResponse response = new ErrorResponse(
      ErrorCode.INTERNAL_SERVER_ERROR.name(),
      ErrorCode.INTERNAL_SERVER_ERROR.getMessage(),
      LocalDateTime.now(),
      request.getRequestURI()
    );
    return ResponseEntity.status(500).body(response);
  }
}
