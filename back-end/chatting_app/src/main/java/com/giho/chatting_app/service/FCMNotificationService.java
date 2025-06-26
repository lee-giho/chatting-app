package com.giho.chatting_app.service;

import com.giho.chatting_app.dto.FCMNotificationRequestDto;
import com.giho.chatting_app.entity.UserFcmToken;
import com.giho.chatting_app.repository.UserFcmTokenRepository;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.FirebaseMessagingException;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class FCMNotificationService {

  @Autowired
  private FirebaseMessaging firebaseMessaging;

  @Autowired
  private UserFcmTokenRepository userFcmTokenRepository;

  public String sendNotificationByToken(FCMNotificationRequestDto fcmNotificationRequestDto) {

    List<UserFcmToken> userFcmToken = userFcmTokenRepository.findByUserId(fcmNotificationRequestDto.getTargetUserId());

    System.out.println(userFcmToken);

    if (userFcmToken == null || userFcmToken.isEmpty()) {
      return "해당 사용자의 FCM 토큰이 존재하지 않습니다. tartgetUserId = " + fcmNotificationRequestDto.getTargetUserId();
    }

    int successCount = 0;
    int failCount = 0;

    for (UserFcmToken tokenObj : userFcmToken) {
      String fcmToken = tokenObj.getFcmToken();
      if (fcmToken != null) {
        Notification notification = Notification.builder()
          .setTitle(fcmNotificationRequestDto.getTitle())
          .setBody(fcmNotificationRequestDto.getBody())
          .build();

        Message message = Message.builder()
          .setToken(fcmToken)
          .setNotification(notification)
          .build();

        try {
          firebaseMessaging.send(message);
          successCount++;
        } catch (FirebaseMessagingException e) {
          e.printStackTrace();
          failCount++;
        }
      } else {
        failCount++;
      }
    }
    return String.format("알림 전송 완료: 성공 %d건, 실패 %d건, targetUserId = %s",
      successCount, failCount, fcmNotificationRequestDto.getTargetUserId());
  }
}
