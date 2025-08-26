import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatService {
  late io.Socket _socket;

  io.Socket get socket => _socket;

  void connect(String token, Function onConnect, Function onDisconnect) {
    _socket = io.io(
      BaseUrls.socketUrl, // replace with backend URL
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setQuery({'token': token}) // pass token if backend requires
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) => onConnect());
    _socket.onDisconnect((_) => onDisconnect());
  }

  void disconnect() {
    _socket.dispose();
  }

  // ================= SOCKET EMIT METHODS =================

  void sendMessage({
    required int receiverId,
    required int studentId,
    required String message,
  }) {
    _socket.emit("sendMessage", {
      "receiver_id": receiverId,
      "student_id": studentId,
      "message": message,
    });
  }

  void getMessages(int opponentId) {
    _socket.emit("getMessages", {"opponentId": opponentId});
  }

  void deleteMessage(int messageId) {
    _socket.emit("deleteMessage", {"messageId": messageId});
  }

  void getUsersList({int page = 1, int limit = 10}) {
    _socket.emit("getUsersListandLatestMessage", {
      "page": page,
      "limit": limit,
    });
  }

  void getFirstUnseenMessage(int opponentId) {
    _socket.emit("getFirstUnseenMessage", {"opponentId": opponentId});
  }
}
