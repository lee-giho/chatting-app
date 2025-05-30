package com.giho.chatting_app.config;

import jakarta.annotation.PostConstruct;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer{

  @Value("${PROFILE_IMAGE_PATH}")
  private String profileImageRelativePath;

  @Override
  public void addResourceHandlers(ResourceHandlerRegistry registry) {
    registry.addResourceHandler("/images/profile/**")
      .addResourceLocations("file:" + profileImageRelativePath + "/");
  }

  @PostConstruct
  public void init() {
    System.out.println(">>> PROFILE_IMAGE_PATH: " + profileImageRelativePath);
  }
}
