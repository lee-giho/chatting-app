package com.giho.chatting_app.domain;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Builder
@Table(name = "chat_room")
public class ChatRoom {
  @Id
  @Column(name = "id", nullable = false) 
  private String id;

  @Column(name = "creator_id", nullable = false)
  private String creatorId;

  @Column(name = "visitor_id", nullable = false)
  private String visitorId;

  @Column(name = "created_at", nullable = false, updatable = false, insertable = false)
  private LocalDateTime createdAt;

  // createdAt을 자동 생성하는 생성자 추가
  public ChatRoom(String id, String creatorId, String visitorId) {
    this.id = id;
    this.creatorId = creatorId;
    this.visitorId = visitorId;
    this.createdAt = LocalDateTime.now();
  }
}