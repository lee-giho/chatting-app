package com.giho.chatting_app.dto;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

@Data
public class UploadProfileImageRequest {
  private MultipartFile profileImage;
}
