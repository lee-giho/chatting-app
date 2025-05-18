package com.giho.chatting_app.service;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.domain.ChatRoom;
import com.giho.chatting_app.domain.User;
import com.giho.chatting_app.dto.ChatRoomAndFriendInfo;
import com.giho.chatting_app.dto.ChatRoomAndUserInfoList;
import com.giho.chatting_app.dto.ChatRoomIdResponse;
import com.giho.chatting_app.dto.UserInfo;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.ChatRoomRepository;
import com.giho.chatting_app.repository.UserRepository;
import com.giho.chatting_app.util.JwtProvider;

@Service
public class ChatRoomService {
  
  private final Map<String, ChatRoom> chatRooms = new LinkedHashMap<>();

  @Autowired
  private JwtProvider jwtProvider;

  @Autowired
  private ChatRoomRepository chatRoomRepository;

  @Autowired
  private UserRepository userRepository;

  // // 채팅방 생성
  // public ChatRoom createRoom(String name) {
  //   String roomId = UUID.randomUUID().toString();
  //   ChatRoom chatRoom = new ChatRoom(roomId, name);
  //   chatRooms.put(roomId, chatRoom);
  //   return chatRoom;
  // }

  // 채팅방 생성
  public String createRoom(String myId, String friendId) {
    String chatRoomId = UUID.randomUUID().toString();
    ChatRoom newChatRoom = new ChatRoom(chatRoomId, myId, friendId);
    ChatRoom savedChatRoom = chatRoomRepository.save(newChatRoom);

    return savedChatRoom.getId();
  }

  // 채팅방 id 반환, 채팅방 확인 후 없으면 생성
  public ChatRoomIdResponse getChatRoomId(String token, String friendId) {
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String myId = jwtProvider.getUserId(tokenWithoutBearer);

    // 내가 만든 채팅방이 있는지 확인
    Optional<ChatRoom> chatRoomOpt = chatRoomRepository.findByCreatorIdAndVisitorId(myId, friendId);

    if (chatRoomOpt.isEmpty()) {
      // 친구가 만든 채팅방이 있는지 확인
      chatRoomOpt = chatRoomRepository.findByCreatorIdAndVisitorId(friendId, myId);
    }

    // 채팅방이 존재하면 반환
    if (chatRoomOpt.isPresent()) {
      return new ChatRoomIdResponse(chatRoomOpt.get().getId());
    } else {
      String chatRoomId = createRoom(myId, friendId);
      return new ChatRoomIdResponse(chatRoomId);
    }
  }

  // 모든 채팅방 반환
  public ChatRoomAndUserInfoList getAllRooms(String token) {
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String myId = jwtProvider.getUserId(tokenWithoutBearer);

    List<ChatRoom> chatRooms = new ArrayList<>();

    // 내가 만든 채팅방이 있는지 확인 후 추가
    chatRoomRepository.findByCreatorId(myId)
      .ifPresent(chatRooms::add);

    // 친구가 만든 채팅방이 있는지 확인 후 추가
    chatRoomRepository.findByVisitorId(myId)
      .ifPresent(chatRooms::add);

    if (chatRooms.isEmpty()) {
      return ChatRoomAndUserInfoList.builder()
        .chatRoomInfos(null)
        .build();
    }

    List<ChatRoomAndFriendInfo> chatRoomAndFriendInfos = chatRooms.stream()
      .map(chatRoom -> {
        String friendId = chatRoom.getCreatorId().equals(myId)
          ? chatRoom.getVisitorId()
          : chatRoom.getCreatorId();

        User user = userRepository.findById(friendId)
          .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

        UserInfo userInfo = UserInfo.builder()
          .id(user.getId())
          .nickName(user.getNickName())
          .profileImage(user.getProfileImage())
          .build();

        return ChatRoomAndFriendInfo.builder()
          .chatRoomInfo(chatRoom)
          .friendInfo(userInfo)
          .build();
      }).collect(Collectors.toList());

    return ChatRoomAndUserInfoList.builder()
      .chatRoomInfos(chatRoomAndFriendInfos)
      .build();
  }

  // 특정 채팅방 조회
  public ChatRoom findRoomById(String roomId) {
    return chatRooms.get(roomId);
  }
}
