package com.giho.chatting_app.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.entity.ChatMessages;
import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.ChatMessageList;
import com.giho.chatting_app.repository.ChatMessagesRepository;

@Service
public class ChatMessagesService {
  
  @Autowired
  private ChatMessagesRepository chatMessageRepository;

  public ChatMessageList getChatMessageList(String chatRoomId) {
    List<ChatMessages> chatMessageList = chatMessageRepository.findByRoomIdOrderBySentAtAsc(chatRoomId);
    return ChatMessageList.builder()
      .chatMessageList(chatMessageList)
      .build();
  }

  public ChatMessages getLastChatMessages(String chatRoomId) {
    ChatMessages chatMessages = chatMessageRepository.findTop1ByRoomIdOrderBySentAtDesc(chatRoomId);
    return chatMessages;
  }

  public BooleanResponse deleteChatMessages(String chatRoomId) {
    List<ChatMessages> chatMessages = chatMessageRepository.findByRoomId(chatRoomId);

    chatMessageRepository.deleteAll(chatMessages);

    return new BooleanResponse(true);
  }
}
