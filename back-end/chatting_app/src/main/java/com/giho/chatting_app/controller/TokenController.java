package com.giho.chatting_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.JwtTokens;
import com.giho.chatting_app.service.TokenService;

@RestController
@RequestMapping("/api/token")
public class TokenController {
  
  @Autowired
  private TokenService tokenService;

  // token 검증 엔드포인트
  @GetMapping("/validation")
  public ResponseEntity<BooleanResponse> validateToken(@RequestHeader("Authorization") String token) {
    BooleanResponse booleanResponse = tokenService.validateToken(token);
    return ResponseEntity.ok(booleanResponse);
  }

  // accessToken 재발급 엔드포인트
  @PostMapping("/reissuance")
  public ResponseEntity<JwtTokens> tokenReissuance(@RequestHeader("Authorization") String token) {
    JwtTokens jwtTokens = tokenService.refreshToken(token);
    return ResponseEntity.ok(jwtTokens);
  }
}
