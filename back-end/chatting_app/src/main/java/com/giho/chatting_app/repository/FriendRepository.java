package com.giho.chatting_app.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giho.chatting_app.domain.Friend;
import com.giho.chatting_app.domain.FriendStatus;

public interface FriendRepository extends JpaRepository<Friend, String>{
  Optional<Friend> findByUserIdAndFriendId(String userId, String friendId);
  List<Friend> findAllByFriendIdAndStatus(String friendId, FriendStatus status);
  int countByFriendIdAndStatus(String friendId, FriendStatus status);
}