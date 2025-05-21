package com.giho.chatting_app.repository;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;

import com.giho.chatting_app.domain.ChatMessages;

public interface ChatMessagesRepository extends MongoRepository<ChatMessages, String> {
  List<ChatMessages> findByRoomIdOrderBySentAtAsc(String roomId);
}
