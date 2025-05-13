package com.giho.chatting_app.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.domain.Friend;
import com.giho.chatting_app.domain.FriendStatus;
import com.giho.chatting_app.dto.CountResponse;
import com.giho.chatting_app.repository.FriendRepository;
import com.giho.chatting_app.util.JwtProvider;

@Service
public class FriendService {
  
  @Autowired
  private FriendRepository friendRepository;

  @Autowired
  private JwtProvider jwtProvider;

  public List<Friend> getReceivedFriendRequests(String userId) {
    List<Friend> requests = friendRepository.findAllByFriendIdAndStatus(userId, FriendStatus.REQUESTED);
    return requests;
  }
  
  public CountResponse getRequestFriendCount(String token) {
    
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String myId = jwtProvider.getUserId(tokenWithoutBearer);

    int count = friendRepository.countByFriendIdAndStatus(myId, FriendStatus.REQUESTED);
    return new CountResponse(count);
  }
}
