package com.giho.chatting_app.controller;

import com.giho.chatting_app.dto.BooleanResponse;
import com.giho.chatting_app.dto.BroadcastRoomInfo;
import com.giho.chatting_app.dto.BroadcastRoomList;
import com.giho.chatting_app.dto.CreateBroadcastRoomRequest;
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
  public ResponseEntity<BroadcastRoomInfo> startBroadcast(
          @RequestBody CreateBroadcastRoomRequest createBroadcastRoomRequest,
          @RequestHeader("Authorization") String token) {
    BroadcastRoomInfo broadcastRoomInfo = broadcastRoomService.saveRoomInfo(createBroadcastRoomRequest, token);
    return ResponseEntity.ok(broadcastRoomInfo);
  }

  // 방송 종료 엔드포인트
  @DeleteMapping()
  public ResponseEntity<BooleanResponse> endBroadcast(@RequestParam("roomId") String roomId) {
    BooleanResponse booleanResponse = broadcastRoomService.deleteRoom(roomId);
    return ResponseEntity.ok(booleanResponse);
  }

  // 시청자 입장 시 방 존재 여부 확인 엔드포인트
  @GetMapping("/exists")
  public ResponseEntity<BooleanResponse> checkRoom(@RequestParam("roomId") String roomId) {
    BooleanResponse booleanResponse = broadcastRoomService.existsRoom(roomId);
    return ResponseEntity.ok(booleanResponse);
  }

  // 모든 방 불러오는 엔드포인트
  @GetMapping()
  public ResponseEntity<BroadcastRoomList> getAllRooms() {
    BroadcastRoomList broadcastRoomList = broadcastRoomService.getAllRooms();
    return ResponseEntity.ok(broadcastRoomList);
  }
}
