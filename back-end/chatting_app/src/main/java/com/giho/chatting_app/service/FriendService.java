package com.giho.chatting_app.service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.entity.ChatMessages;
import com.giho.chatting_app.entity.ChatRoom;
import com.giho.chatting_app.entity.Friend;
import com.giho.chatting_app.entity.FriendStatus;
import com.giho.chatting_app.entity.User;
import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.CountResponse;
import com.giho.chatting_app.dto.FriendList;
import com.giho.chatting_app.dto.ReceivedFriendListResponse;
import com.giho.chatting_app.dto.ReceivedFriendRequest;
import com.giho.chatting_app.dto.UserInfo;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.ChatMessagesRepository;
import com.giho.chatting_app.repository.ChatRoomRepository;
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

  @Autowired
  private ChatRoomRepository chatRoomRepository;

  @Autowired
  private ChatMessagesRepository chatMessagesRepository;

  // 받은 친구 요청 목록 반환
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
  
  // 받은 친구 요청 수 반환
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

  // 친구 목록 반환
  public FriendList getFriendList(String token) {

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String myId = jwtProvider.getUserId(tokenWithoutBearer);

    // 내가 먼저 요청을 보낸 친구 목록
    List<Friend> friendList1 = friendRepository.findAllByUserIdAndStatus(myId, FriendStatus.ACCEPTED);

    // 상대방이 먼저 요청을 보낸 친구 목록
    List<Friend> friendList2 = friendRepository.findAllByFriendIdAndStatus(myId, FriendStatus.ACCEPTED);

    List<UserInfo> userInfos = Stream.concat(
      friendList1.stream().map(friend -> {
        User user = userRepository.findById(friend.getFriendId())
          .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        return UserInfo.builder()
          .id(user.getId())
          .nickName(user.getNickName())
          .profileImage(user.getProfileImage())
          .build();
      }),
      friendList2.stream().map(friend -> {
        User user = userRepository.findById(friend.getUserId())
          .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));
        return UserInfo.builder()
          .id(user.getId())
          .nickName(user.getNickName())
          .profileImage(user.getProfileImage())
          .build();
      })
    ).collect(Collectors.toList());

    return new FriendList(userInfos);
  }

  // 친구 삭제
  public BooleanResponse deleteFriend(String token, String friendId) {
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String myId = jwtProvider.getUserId(tokenWithoutBearer);

    // 내가 요청을 보낸 Friend
    Optional<Friend> friendOpt = friendRepository.findByUserIdAndFriendIdAndStatus(myId, friendId, FriendStatus.ACCEPTED);
    if (friendOpt.isEmpty()) {
      // 상대방이 요청을 보낸 Friend
      friendOpt = friendRepository.findByUserIdAndFriendIdAndStatus(friendId, myId, FriendStatus.ACCEPTED);
    }
    Friend friend = friendOpt.orElseThrow(() -> new CustomException(ErrorCode.FRIEND_NOT_FOUND));

    // 내가 만든 ChatRoom
    Optional<ChatRoom> chatRoomOpt = chatRoomRepository.findByCreatorIdAndVisitorId(myId, friendId);
    if (chatRoomOpt.isEmpty()) {
      // 상대방이 만든 ChatRoom
      chatRoomOpt = chatRoomRepository.findByCreatorIdAndVisitorId(friendId, myId);
    }

    if (chatRoomOpt.isPresent()) {
      // 채팅방에 있는 메세지 삭제
      List<ChatMessages> chatMessages = chatMessagesRepository.findByRoomId(chatRoomOpt.get().getId());
      chatMessagesRepository.deleteAll(chatMessages);

      // 채팅방 삭제
      chatRoomRepository.delete(chatRoomOpt.get());
    }

    // 친구 삭제
    friendRepository.delete(friend);

    return new BooleanResponse(true);
  }
}
