package com.giho.chatting_app.repository;

import com.giho.chatting_app.dto.BroadcastRoomInfo;
import com.giho.chatting_app.dto.BroadcastRoomList;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Repository
public class BroadcastRoomRepository {
  private static final String ROOM_KEY_PREFIX = "broadcast_room:";

  @Autowired
  private RedisTemplate<String, String> redisTemplate;

  public void save(BroadcastRoomInfo broadcastRoomInfo) {
    String key = ROOM_KEY_PREFIX + broadcastRoomInfo.getRoomId();
    Map<String, String> roomInfo = new HashMap<>();
    roomInfo.put("roomId", broadcastRoomInfo.getRoomId());
    roomInfo.put("roomName", broadcastRoomInfo.getRoomName());
    roomInfo.put("senderNickName", broadcastRoomInfo.getSenderNickName());

    redisTemplate.opsForHash().putAll(key, roomInfo);
  }

  public void delete(String roomId) {
    redisTemplate.delete(ROOM_KEY_PREFIX + roomId);
  }

  public boolean exists(String roomId) {
    return redisTemplate.hasKey(ROOM_KEY_PREFIX + roomId);
  }

  public BroadcastRoomList findAll() {
    Set<String> keys = redisTemplate.keys(ROOM_KEY_PREFIX + "*");

    List<BroadcastRoomInfo> broadcastRoomInfoList = keys.stream()
            .map(key -> {
              Map<Object, Object> broadcastRoom = redisTemplate.opsForHash().entries(key);
              return BroadcastRoomInfo.builder()
                      .roomId(String.valueOf(broadcastRoom.get("roomId")))
                      .roomName(String.valueOf(broadcastRoom.get("roomName")))
                      .senderNickName(String.valueOf(broadcastRoom.get("senderNickName")))
                      .build();
            })
            .toList();

    return new BroadcastRoomList(broadcastRoomInfoList);
  }
}
