package com.giho.chatting_app.event;

import java.time.LocalDateTime;

public record ChatMessageEvent(String messageId, String roomId, String content, String sender, LocalDateTime sentAt) {
  
}
