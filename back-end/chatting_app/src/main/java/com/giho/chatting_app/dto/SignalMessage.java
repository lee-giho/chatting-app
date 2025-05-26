package com.giho.chatting_app.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SignalMessage {
  private String type; // offer & answer & ice
  private String sdp;
  private String candidate;
  private String sdpMid;
  private int sdpMLineIndex;
  private String room;
}
