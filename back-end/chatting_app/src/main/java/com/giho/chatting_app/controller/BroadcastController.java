package com.giho.chatting_app.controller;

import com.giho.chatting_app.service.redis.BroadcastRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/broadcast")
public class BroadcastController {

  private final BroadcastRoomService broadcastRoomService;

  // 방송 시작 (방 만들기) 엔드포인트
  @PostMapping()
  public ResponseEntity<String> startBroadcast(@RequestParam("roomId") String roomId) {
    broadcastRoomService.saveRoomInfo(roomId, "ACTIVE");
    return ResponseEntity.ok("Broadcast room created: " + roomId);
  }

  // 방송 종료 엔드포인트
  @DeleteMapping()
  public ResponseEntity<String> endBroadcast(@RequestParam("roomId") String roomId) {
    broadcastRoomService.deleteRoom(roomId);
    return ResponseEntity.ok("Broadcast room deleted: " + roomId);
  }

  // 시청자 입장 시 방 존재 여부 확인 엔드포인트
  @GetMapping("/exists")
  public ResponseEntity<Boolean> checkRoom(@RequestParam("roomId") String roomId) {
    return ResponseEntity.ok(broadcastRoomService.existsRoom(roomId));
  }
}
