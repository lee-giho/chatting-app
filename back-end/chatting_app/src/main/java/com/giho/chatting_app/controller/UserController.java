package com.giho.chatting_app.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.SearchUserList;
import com.giho.chatting_app.dto.UploadProfileImageRequest;
import com.giho.chatting_app.dto.UserInfo;
import com.giho.chatting_app.service.UserService;

@RestController
@RequestMapping("/api/user")
public class UserController {

  @Autowired
  private UserService userService;

  // 내 정보 가져오는 엔드포인트
  @GetMapping("/myInfo")
  public ResponseEntity<UserInfo> getMyInfo(@RequestHeader("Authorization") String token) {
    UserInfo userInfo = userService.getMyInfo(token);
    return ResponseEntity.ok(userInfo);
  }

  // 프로필 이미지 저장하는 엔드포인트
  @PostMapping("/profileImage")
  public ResponseEntity<BooleanResponse> uploadProfileImage(@RequestHeader("Authorization") String token, @ModelAttribute UploadProfileImageRequest uploadProfileImageRequest) {
    BooleanResponse booleanResponse = userService.saveProfileImage(token, uploadProfileImageRequest);
    return ResponseEntity.ok(booleanResponse);
  }

  // 프로필 이미지 삭제하고 기본으로 바꾸는 엔드포인트
  @DeleteMapping("/profileImage/default")
  public ResponseEntity<BooleanResponse> deleteProfileImage(@RequestHeader("Authorization") String token) {
    BooleanResponse booleanResponse = userService.deleteProfileImage(token);
    return ResponseEntity.ok(booleanResponse);
  }

  // keyword로 사용자 검색하고 리스트 반환하는 엔드포인트
  @GetMapping("/keyword")
  public ResponseEntity<SearchUserList> searchUsers(@RequestHeader("Authorization") String token, @RequestParam("keyword") String keyword) {
    SearchUserList searchUserList = userService.searchUserByKeyword(token, keyword);
    return ResponseEntity.ok(searchUserList);
  }
}
