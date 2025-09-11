import 'package:acadobs/features/chats/data/services/chat_services.dart';
import 'package:flutter/foundation.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  bool _connected = false;
  bool get isConnected => _connected;

  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  final List<Map<String, dynamic>> _usersList = [];
  List<Map<String, dynamic>> get usersList => List.unmodifiable(_usersList);

  bool _isLoadingUsers = false;
  bool get isLoadingUsers => _isLoadingUsers;

  void connect(String token) {
    _chatService.connect(
      token,
      () {
        _connected = true;
        _setupListeners();
        notifyListeners();
        debugPrint("✅ Connected to chat server");
        // Load user list when connected
        loadUsersList();
      },
      () {
        _connected = false;
        notifyListeners();
        debugPrint("❌ Disconnected from chat server");
      },
    );
  }

  void disconnect() {
    _chatService.disconnect();
    _connected = false;
    notifyListeners();
  }

  void _setupListeners() {
    final socket = _chatService.socket;

    socket.off("newMessage"); // 👈 remove old listener
    socket.off("messages");
    socket.off("messageDeleted");
    socket.off("usersList");

    socket.on("newMessage", (data) {
      _messages.add(Map<String, dynamic>.from(data));
      notifyListeners();
    });

    socket.on("messages", (data) {
      _messages.clear();
      for (var msg in data) {
        _messages.add(Map<String, dynamic>.from(msg));
      }
      notifyListeners();
    });

    socket.on("messageDeleted", (data) {
      _messages.removeWhere((m) => m["id"] == data["messageId"]);
      notifyListeners();
    });

    socket.on("usersList", (data) {
      debugPrint("📩 [SOCKET EVENT] usersList -> $data");

      _usersList.clear();
      for (var convo in data["conversations"]) {
        _usersList.add(Map<String, dynamic>.from(convo));
      }
      _isLoadingUsers = false; // 👈 stop loading when data received
      notifyListeners();
    });
  }

  // ================= PUBLIC METHODS =================

  void sendMessage({
    required int receiverId,
    int? studentId,
    required String message,
  }) {
    debugPrint(
      "➡️ Sending message: $message to $receiverId (studentId: $studentId)",
    );

    _chatService.sendMessage(
      receiverId: receiverId,
      studentId: studentId ?? 0,
      message: message,
    );
  }

  void getMessages(int opponentId) {
    _chatService.getMessages(opponentId);
  }

  void deleteMessage(int messageId) {
    _chatService.deleteMessage(messageId);
  }

  void loadUsersList({int page = 1, int limit = 10}) {
    _isLoadingUsers = true; 
    notifyListeners();
    _chatService.getUsersList(page: page, limit: limit);
  }
}
