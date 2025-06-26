package com.giho.chatting_app.repository;


import com.giho.chatting_app.entity.UserFcmToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserFcmTokenRepository extends JpaRepository<UserFcmToken, Long> {
  Optional<UserFcmToken> findByUserIdAndDeviceTypeAndDeviceInfo(String userId, String deviceType, String deviceInfo);

  List<UserFcmToken> findByUserId(String userId);
}
