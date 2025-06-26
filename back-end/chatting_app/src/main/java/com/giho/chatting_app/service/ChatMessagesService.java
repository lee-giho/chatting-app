package com.giho.chatting_app.service;

import java.util.List;

import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.util.JwtProvider;
import com.giho.chatting_app.webSocket.WebSocketMessageSender;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.entity.ChatMessages;
import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.ChatMessageList;
import com.giho.chatting_app.repository.ChatMessagesRepository;

@Service
@RequiredArgsConstructor
public class ChatMessagesService {
  

  private final ChatMessagesRepository chatMessageRepository;

  private final WebSocketMessageSender messageSender;

  private final JwtProvider jwtProvider;

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

  public void markMessageAsRead(String token, String messageId) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(tokenWithoutBearer);

    ChatMessages chatMessages = chatMessageRepository.findById(messageId)
      .orElseThrow(() -> new CustomException(ErrorCode.MESSAGE_NOT_FOUND));

    if (!chatMessages.getReadBy().contains(userId)) {
      chatMessages.getReadBy().add(userId);
      chatMessageRepository.save(chatMessages);

      messageSender.sendReadReceipt(chatMessages.getRoomId(), messageId, userId);
    }
  }
}
