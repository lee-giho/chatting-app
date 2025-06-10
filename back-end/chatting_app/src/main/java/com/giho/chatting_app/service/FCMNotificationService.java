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

import java.util.Optional;

@Service
public class FCMNotificationService {

  @Autowired
  private FirebaseMessaging firebaseMessaging;

  @Autowired
  private UserFcmTokenRepository userFcmTokenRepository;

  public String sendNotificationByToken(FCMNotificationRequestDto fcmNotificationRequestDto) {

    Optional<UserFcmToken> userFcmToken = userFcmTokenRepository.findByUserId(fcmNotificationRequestDto.getTargetUserId());

    if (userFcmToken.isPresent()) {
      String fcmToken = userFcmToken.get().getFcmToken();
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
          return "알림을 성공적으로 전송했습니다. targetUserId = " + fcmNotificationRequestDto.getTargetUserId();
        } catch (FirebaseMessagingException e) {
          e.printStackTrace();
          return "알림 보내기를 실패했습니다. targetUserId = " + fcmNotificationRequestDto.getTargetUserId();
        }
      } else {
        return "서버에 저장된 해당 유저의 FcmToken이 존재하지 않습니다. targetUserId = " + fcmNotificationRequestDto.getTargetUserId();
      }
    } else {
      return "해당 유저가 존재하지 않습니다. targetUserId = " + fcmNotificationRequestDto.getTargetUserId();
    }
  }
}
