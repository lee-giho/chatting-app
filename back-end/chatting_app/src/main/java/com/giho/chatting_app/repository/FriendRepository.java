package com.giho.chatting_app.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giho.chatting_app.entity.Friend;
import com.giho.chatting_app.entity.FriendStatus;

public interface FriendRepository extends JpaRepository<Friend, String>{
  Optional<Friend> findByUserIdAndFriendId(String userId, String friendId);
  Optional<Friend> findByUserIdAndFriendIdAndStatus(String userId, String friendId, FriendStatus status);
  List<Friend> findAllByFriendIdAndStatus(String friendId, FriendStatus status);
  List<Friend> findAllByUserIdAndStatus(String userId, FriendStatus status);
  int countByFriendIdAndStatus(String friendId, FriendStatus status);
  boolean existsByUserIdAndFriendIdAndStatus(String UserId, String FriendId, FriendStatus status);
}