package com.giho.chatting_app.event;

import java.time.LocalDateTime;
import java.util.Set;

public record ChatMessageEvent(String id, String roomId, String sender, String content, LocalDateTime sentAt, Set<String> readBy) {
  
}
