package com.giho.chatting_app.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.domain.Friend;
import com.giho.chatting_app.domain.FriendStatus;
import com.giho.chatting_app.repository.FriendRepository;

@Service
public class FriendService {
  
  @Autowired
  private FriendRepository friendRepository;

  public List<Friend> getReceivedFriendRequests(String userId) {
    List<Friend> requests = friendRepository.findAllByFriendIdAndStatus(userId, FriendStatus.REQUESTED);
    return requests;
  }  

}
