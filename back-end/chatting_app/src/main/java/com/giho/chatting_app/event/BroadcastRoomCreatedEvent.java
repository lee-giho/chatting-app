package com.giho.chatting_app.event;

public record BroadcastRoomCreatedEvent(String roomId, String roomName, String senderNickName) {

}
