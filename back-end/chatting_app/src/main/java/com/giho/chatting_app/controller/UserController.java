package com.giho.chatting_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.UploadProfileImageRequest;
import com.giho.chatting_app.dto.UserInfo;
import com.giho.chatting_app.service.UserService;

@RestController
@RequestMapping("/api/user")
public class UserController {

  @Autowired
  private UserService userService;

  @GetMapping("/myInfo")
  public ResponseEntity<UserInfo> getMyInfo(@RequestHeader("Authorization") String token) {
    UserInfo userInfo = userService.getMyInfo(token);
    return ResponseEntity.ok(userInfo);
  }

  @PostMapping("/profileImage")
  public ResponseEntity<BooleanResponse> uploadProfileImage(@RequestHeader("Authorization") String token, @ModelAttribute UploadProfileImageRequest uploadProfileImageRequest) {
    BooleanResponse booleanResponse = userService.saveProfileImage(token, uploadProfileImageRequest);
    return ResponseEntity.ok(booleanResponse);
  }

  @DeleteMapping("/profileImage/default")
  public ResponseEntity<BooleanResponse> deleteProfileImage(@RequestHeader("Authorization") String token) {
    BooleanResponse booleanResponse = userService.deleteProfileImage(token);
    return ResponseEntity.ok(booleanResponse);
  }
}
