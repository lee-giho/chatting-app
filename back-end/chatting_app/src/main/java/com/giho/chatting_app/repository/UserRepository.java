package com.giho.chatting_app.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.giho.chatting_app.domain.User;

public interface UserRepository extends JpaRepository<User, String> {
  
}
