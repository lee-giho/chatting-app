package com.giho.chatting_app.service;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.entity.User;
import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.SearchUser;
import com.giho.chatting_app.dto.SearchUserList;
import com.giho.chatting_app.dto.UploadProfileImageRequest;
import com.giho.chatting_app.dto.UserInfo;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.FriendRepository;
import com.giho.chatting_app.repository.UserRepository;
import com.giho.chatting_app.util.JwtProvider;

@Service
public class UserService {
  
  @Autowired
  private UserRepository userRepository;

  @Autowired
  private JwtProvider jwtProvider;

  @Autowired
  private FriendRepository friendRepository;

  @Autowired
  private FriendService friendService;

  @Value("${PROFILE_IMAGE_PATH}")
  private String profileImagePath;

  // 내 정보 조회
  public UserInfo getMyInfo(String token) {
    
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(tokenWithoutBearer);

    User user = userRepository.findById(userId)
      .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

    UserInfo userInfo = UserInfo.builder()
      .id(user.getId())
      .nickName(user.getNickName())
      .profileImage(user.getProfileImage())
      .build();

    return userInfo;
  }

  // 프로필 사진 저장
  public BooleanResponse saveProfileImage(String token, UploadProfileImageRequest uploadProfileImageRequest) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(tokenWithoutBearer);

    User user = userRepository.findById(userId)
      .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

    try {
      // 기존 이미지 삭제
      String oldProfileImageName = user.getProfileImage();
      if (!oldProfileImageName.equals("default")) {
        File oldProfileImage = new File(profileImagePath, oldProfileImageName);
        if (oldProfileImage.exists()) {
          oldProfileImage.delete();
        } else {
          throw new CustomException(ErrorCode.FILE_NOT_FOUND);
        }
      }
    } catch (Exception e) {
      throw new CustomException(ErrorCode.FILE_DELETE_ERROR);
    }

    // 새로운 이미지 처리
    String newProfileImageName = UUID.randomUUID() + "_" + uploadProfileImageRequest.getProfileImage().getOriginalFilename();
    File saveDir = new File(profileImagePath);
    System.out.println(saveDir.exists());
    if (!saveDir.exists()) { // 폴더 없으면 생성
      saveDir.mkdirs();
    }
    System.out.println(saveDir.exists());
    File newProfileImage = new File(saveDir, newProfileImageName);


    try {
      uploadProfileImageRequest.getProfileImage().transferTo(newProfileImage);
      user.setProfileImage(newProfileImageName);
      userRepository.save(user);
      return new BooleanResponse(true);
    } catch (IOException e) {
      throw new CustomException(ErrorCode.FILE_STORAGE_ERROR);
    }
  }

  // 기본 프로필 사진으로 변경
  public BooleanResponse deleteProfileImage(String token) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(tokenWithoutBearer);

    User user = userRepository.findById(userId)
      .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

    try {
      // 기존 이미지 삭제
      String oldProfileImageName = user.getProfileImage();
      if (!oldProfileImageName.equals("default")) {
        File oldProfileImage = new File(profileImagePath, oldProfileImageName);
        if (oldProfileImage.exists()) {
          oldProfileImage.delete();
        } else {
          throw new CustomException(ErrorCode.FILE_NOT_FOUND);
        }
      }
    } catch (Exception e) {
      throw new CustomException(ErrorCode.FILE_DELETE_ERROR);
    }

    user.setProfileImage("default");
    userRepository.save(user);

    return new BooleanResponse(true);
  }

  // keyword로 사용자 검색
  public SearchUserList searchUserByKeyword(String token, String keyword) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String myId = jwtProvider.getUserId(tokenWithoutBearer);

    List<User> userList = userRepository.findByIdOrNickName(keyword);

    List<UserInfo> users = userList.stream()
      .filter(user -> !user.getId().equals(myId)) // 내 정보는 제외
      .map(user -> UserInfo.builder()
        .id(user.getId())
        .nickName(user.getNickName())
        .profileImage(user.getProfileImage())
        .build())
      .collect(Collectors.toList());

    List<SearchUser> searchUsers = users.stream()
      .map(searchUser -> SearchUser.builder()
        .userInfo(searchUser)
        .friend(
          friendService.isFriend(myId, searchUser.getId())
        )
        .build())
      .collect(Collectors.toList());



    return new SearchUserList(searchUsers);
  }

  public UserInfo userToUserInfo(String id) {
    User user = userRepository.findById(id)
      .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

    UserInfo userInfo = UserInfo.builder()
      .id(user.getId())
      .nickName(user.getNickName())
      .profileImage(user.getProfileImage())
      .build();
    
    return userInfo;
  }
}
