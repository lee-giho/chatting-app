package com.giho.chatting_app.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giho.chatting_app.domain.ChatRoom;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, String> {
  Optional<ChatRoom> findByCreatorIdAndVisitorId(String creatorId, String visitorId);
  List<ChatRoom> findByCreatorIdOrVisitorIdOrderByCreatedAtDesc(String creatorId, String visitorId);
}
