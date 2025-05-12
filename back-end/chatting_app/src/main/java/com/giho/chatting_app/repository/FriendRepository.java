package com.giho.chatting_app.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giho.chatting_app.domain.Friend;

public interface FriendRepository extends JpaRepository<Friend, String>{
  Optional<Friend> findByUserIdAndFriendId(String userId, String friendId);
}
