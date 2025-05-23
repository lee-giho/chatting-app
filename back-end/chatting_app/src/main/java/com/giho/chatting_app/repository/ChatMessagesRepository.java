package com.giho.chatting_app.repository;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.giho.chatting_app.domain.ChatMessages;

public interface ChatMessagesRepository extends MongoRepository<ChatMessages, String> {
  List<ChatMessages> findByRoomIdOrderBySentAtAsc(String roomId);

  // 가장 최신 메세지 가져오기
  ChatMessages findTop1ByRoomIdOrderBySentAtDesc(String roomId);
}
