package com.giho.chatting_app.service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.giho.chatting_app.domain.ChatMessages;
import com.giho.chatting_app.domain.ChatRoom;
import com.giho.chatting_app.domain.User;
import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.ChatRoomAndFriendInfo;
import com.giho.chatting_app.dto.ChatRoomAndUserInfoList;
import com.giho.chatting_app.dto.ChatRoomIdResponse;
import com.giho.chatting_app.dto.ParticipatingUsersInfo;
import com.giho.chatting_app.dto.UserInfo;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.ChatMessagesRepository;
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

  @Autowired
  private UserService userService;

  @Autowired
  private ChatMessagesRepository chatMessagesRepository;

  @Autowired
  private ChatMessagesService chatMessagesService;

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

    List<ChatRoom> chatRooms = chatRoomRepository.findByCreatorIdOrVisitorIdOrderByCreatedAtDesc(myId, myId);

    if (chatRooms.isEmpty()) {
      return ChatRoomAndUserInfoList.builder()
        .chatRoomInfos(Collections.emptyList())
        .build();
    }

    System.out.println("chatRoom: " + chatRooms);

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

        ChatMessages lastMessage = chatMessagesRepository.findTop1ByRoomIdOrderBySentAtDesc(chatRoom.getId());

        return ChatRoomAndFriendInfo.builder()
          .chatRoomInfo(chatRoom)
          .friendInfo(userInfo)
          .lastMessage(lastMessage)
          .build();
      })
      .sorted(Comparator.comparing(
        (ChatRoomAndFriendInfo info) -> Optional.ofNullable(info.getLastMessage())
          .map(ChatMessages::getSentAt)
          .orElse(LocalDateTime.MIN)
      ).reversed())
      .collect(Collectors.toList());

    System.out.println(chatRoomAndFriendInfos);      

    return ChatRoomAndUserInfoList.builder()
      .chatRoomInfos(chatRoomAndFriendInfos)
      .build();
  }

  // 특정 채팅방 조회
  public ChatRoom findRoomById(String roomId) {
    return chatRooms.get(roomId);
  }

  // 채팅방에 있는 사용자 정보 조회
  public ParticipatingUsersInfo getParticipatingUsersInfo(String token, String chatRoomId) {
    
    ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
      .orElseThrow(() -> new CustomException(ErrorCode.CHATROOM_NOT_FOUND));

    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String myId = jwtProvider.getUserId(tokenWithoutBearer);
      
    String friendId = chatRoom.getCreatorId().equals(myId)
      ? chatRoom.getVisitorId()
      : chatRoom.getCreatorId();

    UserInfo myInfo = userService.userToUserInfo(myId);
    UserInfo friendInfo = userService.userToUserInfo(friendId);

    return ParticipatingUsersInfo.builder()
      .myInfo(myInfo)
      .friendInfo(friendInfo)
      .creatorId(chatRoom.getCreatorId())
      .build();
  }

  public BooleanResponse deleteChatRoom(String chatRoomId) {

    ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
      .orElseThrow(() -> new CustomException(ErrorCode.CHATROOM_NOT_FOUND));

    // 채팅방 메세지 삭제
    BooleanResponse isMessagesDelete = chatMessagesService.deleteChatMessages(chatRoomId);

    chatRoomRepository.delete(chatRoom);
    
    return new BooleanResponse(true);
  }
}
