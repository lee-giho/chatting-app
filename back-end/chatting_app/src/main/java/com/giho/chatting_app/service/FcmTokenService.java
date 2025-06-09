package com.giho.chatting_app.service;

import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.FcmTokenRegisterRequest;
import com.giho.chatting_app.entity.UserFcmToken;
import com.giho.chatting_app.repository.UserFcmTokenRepository;
import com.giho.chatting_app.util.JwtProvider;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
public class FcmTokenService {

  @Autowired
  private UserFcmTokenRepository userFcmTokenRepository;

  @Autowired
  private JwtProvider jwtProvider;

  @Transactional
  public BooleanResponse registerFcmToken(String token, FcmTokenRegisterRequest fcmTokenRegisterRequest) {
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(tokenWithoutBearer);

    // 기기 기준으로 존재하는지 조회
    Optional<UserFcmToken> userFcmTokenOpt = userFcmTokenRepository.findByUserIdAndDeviceTypeAndDeviceInfo(
      userId,
      fcmTokenRegisterRequest.getDeviceType(),
      fcmTokenRegisterRequest.getDeviceInfo()
    );

    if (userFcmTokenOpt.isEmpty()) {
      // 신규 등록
      UserFcmToken userFcmToken = UserFcmToken.builder()
        .userId(userId)
        .fcmToken(fcmTokenRegisterRequest.getFcmToken())
        .deviceType(fcmTokenRegisterRequest.getDeviceType())
        .deviceInfo(fcmTokenRegisterRequest.getDeviceInfo())
        .build();

      userFcmTokenRepository.save(userFcmToken);
    } else {
      UserFcmToken existsUserFcmToken = userFcmTokenOpt.get();
      if (!existsUserFcmToken.getFcmToken().equals(fcmTokenRegisterRequest.getFcmToken())) {
        // 동일한 기기에서 fcmToken만 업데이트된 경우
        existsUserFcmToken.setFcmToken(fcmTokenRegisterRequest.getFcmToken());
        userFcmTokenRepository.save(existsUserFcmToken);
      }
    }
    return new BooleanResponse(true);
  }
}
