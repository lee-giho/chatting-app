package com.giho.chatting_app.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.domain.ChatMessages;
import com.giho.chatting_app.dto.ChatMessageList;
import com.giho.chatting_app.repository.ChatMessagesRepository;

@Service
public class ChatMessagesService {
  
  @Autowired
  private ChatMessagesRepository chatMessageRepository;

  public ChatMessageList getChatMessageList(String chatRoomId) {
    List<ChatMessages> chatMessageList = chatMessageRepository.findByRoomIdOrderBySentAtAsc(chatRoomId);
    System.out.println("chatMessageList: " + chatMessageList);
    return ChatMessageList.builder()
      .chatMessageList(chatMessageList)
      .build();
  }
}
