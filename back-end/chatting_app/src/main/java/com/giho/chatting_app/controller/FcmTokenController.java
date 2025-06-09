package com.giho.chatting_app.controller;

import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.FcmTokenRegisterRequest;
import com.giho.chatting_app.service.FcmTokenService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/fcmToken")
public class FcmTokenController {

  @Autowired
  private FcmTokenService fcmTokenService;

  // FCM Token 저장하는 엔드포인트
  @PostMapping()
  public ResponseEntity<BooleanResponse> saveFcmToken(@RequestHeader("Authorization") String token, @RequestBody FcmTokenRegisterRequest fcmTokenRegisterRequest) {
    BooleanResponse booleanResponse = fcmTokenService.registerFcmToken(token, fcmTokenRegisterRequest);
    return ResponseEntity.ok(booleanResponse);
  }
}
