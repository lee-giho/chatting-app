package com.giho.chatting_app.service.redis;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class BroadcastRoomService {

  private final RedisTemplate<String, Object> redisTemplate;

  private static final String ROOM_KEY_PREFIX = "broadcast_room:";

  // 방송 방 정보 저장
  public void saveRoomInfo(String roomId, Object value) {
    String key = ROOM_KEY_PREFIX + roomId;
    redisTemplate.opsForValue().set(key, value);
  }

  // 방송 방 정보 조회
  public Object getRoomInfo(String roomId) {
    String key = ROOM_KEY_PREFIX + roomId;
    return redisTemplate.opsForValue().get(key);
  }

  // 방송 방 정보 삭제 (송출 종료)
  public void deleteRoom(String roomId) {
    String key = ROOM_KEY_PREFIX + roomId;
    redisTemplate.delete(key);
  }

  // 방 존재 여부 확인
  public boolean existsRoom(String roomId) {
    String key = ROOM_KEY_PREFIX + roomId;
    return Boolean.TRUE.equals(redisTemplate.hasKey(key));
  }
}
