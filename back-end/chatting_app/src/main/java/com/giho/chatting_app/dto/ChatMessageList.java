package com.giho.chatting_app.dto;

import java.util.List;

import com.giho.chatting_app.domain.ChatMessages;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;

@Data
@AllArgsConstructor
@Builder
public class ChatMessageList {
  List<ChatMessages> chatMessageList;
}
