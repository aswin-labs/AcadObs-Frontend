import 'dart:developer';

import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatService {
  late io.Socket _socket;

  io.Socket get socket => _socket;

  void connect(String token, Function onConnect, Function onDisconnect) {
    _socket = io.io(
      BaseUrls.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .enableAutoConnect()
          .build(),
    );

    // ======== Connection Events ========
    _socket.onConnect((_) {
      debugPrint("✅ [SOCKET] Connected with id: ${_socket.id}");
      onConnect();
    });

    _socket.onDisconnect((_) {
      debugPrint("❌ [SOCKET] Disconnected");
      onDisconnect();
    });

    _socket.onConnectError((err) {
      debugPrint("⚠️ [SOCKET] Connect error: $err");
    });

    _socket.onError((err) {
      debugPrint("🚨 [SOCKET] General error: $err");
    });

    _socket.onReconnect((attempt) {
      debugPrint("🔄 [SOCKET] Reconnecting... attempt $attempt");
    });

    _socket.onReconnectError((err) {
      debugPrint("⚡ [SOCKET] Reconnect error: $err");
    });

    _socket.onReconnectFailed((_) {
      debugPrint("🔥 [SOCKET] Reconnect failed");
    });

    // ======== Debug All Incoming Events ========
    _socket.onAny((event, data) {
      log("📩 [SOCKET EVENT] $event -> $data");
    });
  }

  void disconnect() {
    debugPrint("🔌 [SOCKET] Disposing connection");
    _socket.dispose();
  }

  // ================= SOCKET EMIT METHODS =================

  void sendMessage({
    required int receiverId,
    required int studentId,
    required String message,
    required String type,
    required int typeId
  }) {
    final payload = {
      "receiver_id": receiverId,
      "student_id": studentId,
      "message": message,
      "type":type,
      "type_id":typeId
    };
    debugPrint("➡️ [EMIT] sendMessage -> $payload");
    _socket.emit("sendMessage", payload);
  }

  void getMessages(int opponentId) {
    log("➡️ [EMIT] getMessages -> {opponentId: $opponentId}");
    _socket.emit("getMessages", {"opponentId": opponentId});
  }

  void deleteMessage(int messageId) {
    debugPrint("➡️ [EMIT] deleteMessage -> {messageId: $messageId}");
    _socket.emit("deleteMessage", {"messageId": messageId});
  }

  void getUsersList({int page = 1, int limit = 10}) {
    final payload = {"page": page, "limit": limit};
    debugPrint("➡️ [EMIT] getUsersListandLatestMessage -> $payload");
    _socket.emit("getUsersListandLatestMessage", payload);
  }

  void getFirstUnseenMessage(int opponentId) {
    debugPrint("➡️ [EMIT] getFirstUnseenMessage -> {opponentId: $opponentId}");
    _socket.emit("getFirstUnseenMessage", {"opponentId": opponentId});
  }

  // Get staffs under school
Future<Response> fetchStaffsUnderSchool({required int pageNo, String? query}) async {
  final schoolId = await AuthStorageService().getSchoolIdForParent();
  if (schoolId == null) {
    throw Exception("School ID is null");
  }

  // Build the URL conditionally depending on whether query is present
  String url = "${ApiEndpoints.staffsBySchoolId}/$schoolId?page=$pageNo&limit=10";
  if (query != null && query.isNotEmpty) {
    url += "&q=$query";
  }

  final response = await ApiServices.get(url);
  return response;
}
}
