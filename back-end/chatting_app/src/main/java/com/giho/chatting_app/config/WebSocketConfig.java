package com.giho.chatting_app.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer{

  // WebSocket 연결 엔드포인트 등록
  @Override
  public void registerStompEndpoints(StompEndpointRegistry registry) {
    registry.addEndpoint("/ws-chat").setAllowedOriginPatterns("*");
    registry.addEndpoint("/signaling").setAllowedOriginPatterns("*").withSockJS();
  }

  // 메시지 브로커 설정
  @Override
  public void configureMessageBroker(MessageBrokerRegistry registry) {
    registry.enableSimpleBroker("/topic"); // 서버 -> 클라이언트로 전송되는 구독 경로
    registry.setApplicationDestinationPrefixes("/app"); // 클라이언트 -> 서버로 전송되는 경로
  }
}
