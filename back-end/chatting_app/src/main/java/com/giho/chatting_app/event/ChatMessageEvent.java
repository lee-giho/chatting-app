package com.giho.chatting_app.event;

import java.time.LocalDateTime;

public record ChatMessageEvent(String id, String roomId, String sender, String content, LocalDateTime sentAt) {
  
}
