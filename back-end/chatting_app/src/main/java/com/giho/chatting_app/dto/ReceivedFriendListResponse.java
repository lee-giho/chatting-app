package com.giho.chatting_app.dto;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class ReceivedFriendListResponse {
  List<ReceivedFriendRequest> receivedFriendRequests;
}
