package com.giho.chatting_app.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.giho.chatting_app.domain.User;

public interface UserRepository extends JpaRepository<User, String> {
  boolean existsByNickName(String nickName);

  @Query("SELECT u FROM User u WHERE u.id = :keyword OR u.nickName = :keyword")
  List<User> findByIdOrNickName(@Param("keyword") String keyword);
}
