package com.giho.chatting_app.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.giho.chatting_app.domain.User;
import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.SignUpRequest;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.UserRepository;

@Service
public class AuthService {
  
  @Autowired
  private UserRepository userRepository;

  @Autowired
  private PasswordEncoder passwordEncoder;

  // 아이디 중복확인
  public BooleanResponse checkIdDuplication(String id) {
    boolean idDuplication = userRepository.existsById(id);
    return new BooleanResponse(idDuplication);
  }

  // 닉네임 중복확인
  public BooleanResponse checkNickNameDuplication(String nickName) {
    boolean nickNameDuplication = userRepository.existsByNickName(nickName);
    return new BooleanResponse(nickNameDuplication);
  }

  // 회원가입
  @Transactional
  public BooleanResponse signUp(SignUpRequest signUpRequest) {
    if (userRepository.existsById(signUpRequest.getId())) {
      throw new CustomException(ErrorCode.DUPLICATE_USER_ID);
    }

    if (userRepository.existsByNickName(signUpRequest.getNickName())) {
      throw new CustomException(ErrorCode.DUPLICATE_NICKNAME);
    }

    // User 객체 생성
    User user = User.builder()
      .id(signUpRequest.getId())
      .password(passwordEncoder.encode(signUpRequest.getPassword()))
      .nickName(signUpRequest.getNickName())
      .build();
    userRepository.save(user);

    return new BooleanResponse(true);
  }
  
}
