package com.giho.chatting_app.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.domain.User;
import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.JwtTokens;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.UserRepository;
import com.giho.chatting_app.util.JwtProvider;

@Service
public class TokenService {
  
  @Autowired
  private JwtProvider jwtProvider;

  @Autowired
  private UserRepository userRepository;

  // token 유효성 검사
  public BooleanResponse validateToken(String token) {
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    return new BooleanResponse(jwtProvider.validateToken(tokenWithoutBearer));
  }

  // refreshToken으로 새로운 accessToken 발급
  public JwtTokens refreshToken(String refreshToken) {
    String refreshTokenWithoutBearer = jwtProvider.getTokenWithoutBearer(refreshToken);
    if (!jwtProvider.validateToken(refreshTokenWithoutBearer)) {
      throw new CustomException(ErrorCode.INVALID_REFRESH_TOKEN);
    }

    // refreshtoken이 유효한 경우, 새로운 accessToken을 발급
    String id = jwtProvider.getUserId(refreshTokenWithoutBearer);
    User user = userRepository.findById(id)
      .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

    return JwtTokens.builder()
      .accessToken(jwtProvider.generateAccessToken(user))
      .refreshToken(null)
      .build();
  }
}
