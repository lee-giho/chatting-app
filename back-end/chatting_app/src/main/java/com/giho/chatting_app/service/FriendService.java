package com.giho.chatting_app.service;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.domain.Friend;
import com.giho.chatting_app.domain.FriendStatus;
import com.giho.chatting_app.domain.User;
import com.giho.chatting_app.dto.CountResponse;
import com.giho.chatting_app.dto.ReceivedFriendListResponse;
import com.giho.chatting_app.dto.ReceivedFriendRequest;
import com.giho.chatting_app.dto.UserInfo;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.FriendRepository;
import com.giho.chatting_app.repository.UserRepository;
import com.giho.chatting_app.util.JwtProvider;

@Service
public class FriendService {
  
  @Autowired
  private FriendRepository friendRepository;

  @Autowired
  private JwtProvider jwtProvider;
  
  @Autowired
  private UserRepository userRepository;

  public ReceivedFriendListResponse getReceivedFriendRequests(String token) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String myId = jwtProvider.getUserId(tokenWithoutBearer);

    List<Friend> friends = friendRepository.findAllByFriendIdAndStatus(myId, FriendStatus.REQUESTED);

    List<ReceivedFriendRequest> receivedFriendRequests = friends.stream()
      .filter(friend -> friend.getStatus() == FriendStatus.REQUESTED) // FriendState가 REQUEST가 아니면 제외
      .map(friend -> {
        User user = userRepository.findById(friend.getUserId())
          .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        UserInfo userInfo = UserInfo.builder()
          .id(user.getId())
          .nickName(user.getNickName())
          .profileImage(user.getProfileImage())
          .build();

        return ReceivedFriendRequest.builder()
          .userInfo(userInfo)
          .friend(friend)
          .build();
      })
      .collect(Collectors.toList());

    return new ReceivedFriendListResponse(receivedFriendRequests);
  }
  
  public CountResponse getRequestFriendCount(String token) {
    
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String myId = jwtProvider.getUserId(tokenWithoutBearer);

    int count = friendRepository.countByFriendIdAndStatus(myId, FriendStatus.REQUESTED);
    return new CountResponse(count);
  }

  public Friend isFriend(String myId, String targetId) {
    Friend myFriend = friendRepository.findByUserIdAndFriendId(myId, targetId)
      .orElse(null);
    Friend targetFriend = friendRepository.findByUserIdAndFriendId(targetId, myId)
      .orElse(null);

    if (myFriend != null) {
      return myFriend;
    }

    if (targetFriend != null) {
      return targetFriend;
    }

    return null;
  }
}
