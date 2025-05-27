package com.giho.chatting_app.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class SignalMessage {
  private String type; // offer & answer & ice
  private String sdp;

  private String candidate;
  private String sdpMid;
  private int sdpMLineIndex;

  private String room;
}
