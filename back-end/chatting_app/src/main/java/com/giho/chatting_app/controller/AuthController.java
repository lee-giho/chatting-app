package com.giho.chatting_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.SignUpRequest;
import com.giho.chatting_app.service.AuthService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
  
  @Autowired
  private AuthService authService;

  // 아이디 중복확인 엔드포인트
  @GetMapping("/duplication/id")
  public ResponseEntity<BooleanResponse> checkIdDuplication(@RequestParam("id") String id) {
    BooleanResponse booleanResponse = authService.checkIdDuplication(id);
    System.out.println(booleanResponse);
    return ResponseEntity.ok(booleanResponse);
  }

  // 닉네임 중복확인 엔드포인트
  @GetMapping("/duplication/nickName")
  public ResponseEntity<BooleanResponse> checkNickNameDuplication(@RequestParam("nickName") String nickName) {
    BooleanResponse booleanResponse = authService.checkNickNameDuplication(nickName);
    System.out.println(booleanResponse);
    return ResponseEntity.ok(booleanResponse);
  }

  // 회원가입 엔드포인트
  @PostMapping("/signUp")
  public ResponseEntity<BooleanResponse> signUp(@RequestBody SignUpRequest signUpRequest) {
    BooleanResponse booleanResponse = authService.signUp(signUpRequest);
    System.out.println(booleanResponse);
    return ResponseEntity.ok(booleanResponse);
  }
}
