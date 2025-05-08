package com.giho.chatting_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.DuplicationResponse;
import com.giho.chatting_app.service.AuthService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
  
  @Autowired
  private AuthService authService;

  // 아이디 중복확인 엔드포인트
  @GetMapping("/duplication/id")
  public ResponseEntity<DuplicationResponse> checkIdDuplication(@RequestParam("id") String id) {
    DuplicationResponse duplicationResponse = authService.checkIdDuplication(id);
    System.out.println(duplicationResponse);
    return ResponseEntity.ok(duplicationResponse);
  }
}
