package com.giho.chatting_app.entity;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.Set;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Document(collection = "chatMessages")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessages {
  @Id
  private String id;
  private String roomId;
  private String sender;
  private String content;
  private LocalDateTime sentAt;
  private Set<String> readBy = new HashSet<>();
}
