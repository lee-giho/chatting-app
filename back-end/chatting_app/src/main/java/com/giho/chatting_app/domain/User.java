package com.giho.chatting_app.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Builder
@Table(name = "user")
public class User {
  
  @Id
  @Column(name = "id", nullable = false)
  private String id;

  @Column(name = "password", nullable = false)
  private String password;

  @Column(name = "nickName", nullable = false)
  private String nickName;
}
