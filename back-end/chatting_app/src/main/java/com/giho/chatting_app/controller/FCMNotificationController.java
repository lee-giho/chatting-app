package com.giho.chatting_app.controller;

import com.giho.chatting_app.dto.FCMNotificationRequestDto;
import com.giho.chatting_app.service.FCMNotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/notification")
public class FCMNotificationController {

  @Autowired
  private FCMNotificationService fcmNotificationService;

  @PostMapping()
  public String sendNotificationByToken(@RequestBody FCMNotificationRequestDto fcmNotificationRequestDto) {
    return fcmNotificationService.sendNotificationByToken(fcmNotificationRequestDto);
  }
}
