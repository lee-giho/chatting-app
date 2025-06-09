package com.giho.chatting_app.service.redis;

import com.giho.chatting_app.entity.User;
import com.giho.chatting_app.dto.*;
import com.giho.chatting_app.exception.CustomException;
import com.giho.chatting_app.exception.ErrorCode;
import com.giho.chatting_app.repository.BroadcastRoomRepository;
import com.giho.chatting_app.repository.UserRepository;
import com.giho.chatting_app.service.kafka.KafkaProducerService;
import com.giho.chatting_app.util.JwtProvider;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@RequiredArgsConstructor
@Service
public class BroadcastRoomService {

  private final BroadcastRoomRepository broadcastRoomRepository;

  private final JwtProvider jwtProvider;

  private final UserRepository userRepository;

  private final KafkaProducerService kafkaProducerService;

  // 방송 방 정보 저장
  public BroadcastRoomInfo saveRoomInfo(CreateBroadcastRoomRequest createBroadcastRoomRequest, String token) {
    String tokenWithoutBearer = jwtProvider.getTokenWithoutBearer(token);
    String userId = jwtProvider.getUserId(tokenWithoutBearer);

    User user = userRepository.findById(userId)
            .orElseThrow(() -> new CustomException(ErrorCode.USER_NOT_FOUND));

    System.out.println(createBroadcastRoomRequest);

    BroadcastRoomInfo broadcastRoomInfo = new BroadcastRoomInfo(
      createBroadcastRoomRequest.getRoomId(),
      createBroadcastRoomRequest.getRoomName(),
      user.getNickName()
    );

    broadcastRoomRepository.save(broadcastRoomInfo);

    return broadcastRoomInfo;
  }

  // 방송 방 정보 삭제 (송출 종료)
  public BooleanResponse deleteRoom(String roomId) {
    broadcastRoomRepository.delete(roomId);
    return existsRoom(roomId);
  }

  // 방 존재 여부 확인
  public BooleanResponse existsRoom(String roomId) {
    return new BooleanResponse(broadcastRoomRepository.exists(roomId));
  }

  // 모든 방 불러오기
  public BroadcastRoomList getAllRooms() {
    return broadcastRoomRepository.findAll();
  }
}
