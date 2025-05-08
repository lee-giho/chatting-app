package com.giho.chatting_app.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.giho.chatting_app.dto.DuplicationResponse;
import com.giho.chatting_app.repository.UserRepository;

@Service
public class AuthService {
  
  @Autowired
  private UserRepository userRepository;

  public DuplicationResponse checkIdDuplication(String id) {
    boolean idDuplication = userRepository.existsById(id);
    return new DuplicationResponse(idDuplication);
  }
  
}
