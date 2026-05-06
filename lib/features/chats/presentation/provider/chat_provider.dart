import 'dart:developer';

import 'package:acadobs/features/chats/data/services/chat_services.dart';
import 'package:acadobs/shared/models/staff_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart';

// class ChatProvider with ChangeNotifier {
//   final ChatService _chatService = ChatService();

//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   bool _connected = false;
//   bool get isConnected => _connected;

//   final List<Map<String, dynamic>> _messages = [];
//   List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

//   final List<Map<String, dynamic>> _usersList = [];
//   List<Map<String, dynamic>> get usersList => List.unmodifiable(_usersList);

//   bool _isLoadingUsers = false;
//   bool get isLoadingUsers => _isLoadingUsers;

//   int _currentUserPage = 1;
//   int _totalUserPages = 1;
//   bool get hasMoreUsers => _currentUserPage < _totalUserPages;

//   final List<StaffModel> _staffs = [];
//   List<StaffModel> get staffs => _staffs;

//   int _currentPage = 1;
//   int _totalPages = 1;
//   bool get hasMore => _currentPage < _totalPages;

//   bool _isFetchedOnce = false;

//   // ================= CONNECTION =================

//   void connect(String token) {
//     _chatService.connect(
//       token,
//       () {
//         _connected = true;
//         _setupListeners();
//         notifyListeners();
//         debugPrint("✅ Connected to chat server");

//         // Load user list when connected
//         loadUsersList(reset: true);
//       },
//       () {
//         _connected = false;
//         notifyListeners();
//         debugPrint("❌ Disconnected from chat server");
//       },
//     );
//   }

//   void disconnect() {
//     _chatService.disconnect();
//     _connected = false;
//     notifyListeners();
//   }

//   void _setupListeners() {
//     final socket = _chatService.socket;

//     socket.off("newMessage");
//     socket.off("messages");
//     socket.off("messageDeleted");
//     socket.off("usersList");

//     socket.on("newMessage", (data) {
//       _messages.add(Map<String, dynamic>.from(data));
//       notifyListeners();
//     });

//     socket.on("messages", (data) {
//       _messages.clear();
//       for (var msg in data) {
//         _messages.add(Map<String, dynamic>.from(msg));
//       }
//       notifyListeners();
//     });

//     socket.on("messageDeleted", (data) {
//       _messages.removeWhere((m) => m["id"] == data["messageId"]);
//       notifyListeners();
//     });

//     socket.on("usersList", (data) {
//       debugPrint("📩 [SOCKET EVENT] usersList -> $data");
//       _handleUsersListResponse(data);
//     });
//   }

//   // ================= USERS LIST =================

//   void loadUsersList({bool reset = false, int limit = 10}) {
//     if (_isLoadingUsers) return;

//     // if (_currentUserPage > _totalUserPages) return;

//     _isLoadingUsers = true;
//     notifyListeners();

//     if (reset) {
//       _usersList.clear();
//       _currentUserPage = 1;
//       _totalUserPages = 1;
//     }

//     _chatService.getUsersList(page: _currentUserPage, limit: limit);
//   }

//   void _handleUsersListResponse(dynamic data) {
//     final conversations = List<Map<String, dynamic>>.from(
//       data["conversations"],
//     );

//     // Update pagination from backend if provided
//     if (data["totalPages"] != null) {
//       _totalUserPages = data["totalPages"];
//     }
//     if (data["currentPage"] != null) {
//       _currentUserPage = data["currentPage"];
//     }

//     if (_currentUserPage == 1 && _usersList.isEmpty) {
//       _usersList.clear();
//     }

//     _usersList.addAll(conversations);

//     // If backend doesn’t send totalPages, fallback: infer from page size
//     if (data["totalPages"] == null && conversations.length < 10) {
//       _totalUserPages = _currentUserPage; // stop further loads
//     } else {
//       _currentUserPage++;
//     }

//     _isLoadingUsers = false;
//     notifyListeners();
//   }

//   // ================= MESSAGES =================

//   void sendMessage({
//     required int receiverId,
//     int? studentId,
//     required String message,
//     int? typeId,
//     String? type,
//   }) {
//     debugPrint(
//       "➡️ Sending message: $message to $receiverId (studentId: $studentId)",
//     );

//     _chatService.sendMessage(
//       receiverId: receiverId,
//       studentId: studentId ?? 0,
//       message: message,
//       type: type ?? "msg",
//       typeId: typeId ?? 0,
//     );
//     getMessages(receiverId);
//   }

//   void getMessages(int opponentId) {
//     _chatService.getMessages(opponentId);
//   }

//   void deleteMessage(int messageId) {
//     _chatService.deleteMessage(messageId);
//   }

//   // ================= STAFFS =================

//   Future<void> fetchStaffsUnderSchool({
//     bool loadMore = false,
//     bool forceRefresh = false,
//     String? query,
//   }) async {
//     if (_isLoading) return;

//     if (!loadMore && !forceRefresh && _isFetchedOnce && query == null) return;

//     _isLoading = true;

//     try {
//       if (loadMore) {
//         _currentPage++;
//       } else {
//         _currentPage = 1;
//         _staffs.clear();
//         _isFetchedOnce = false;
//       }

//       final response = await ChatService().fetchStaffsUnderSchool(
//         pageNo: _currentPage,
//         query: query,
//       );

//       if (response.statusCode == 200) {
//         final data = response.data;
//         _totalPages = data['totalPages'];
//         _currentPage = data['currentPage'];
//         final List staffsJson = data['staffs'];
//         final List<StaffModel> fetchedStaffs =
//             staffsJson
//                 .map((jsonItem) => StaffModel.fromJson(jsonItem))
//                 .toList();

//         _staffs.addAll(fetchedStaffs);
//         _isFetchedOnce = true;
//       } else {
//         throw Exception('Failed to fetch staff: ${response.statusCode}');
//       }
//     } catch (e) {
//       log(e.toString());
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }

class ChatProvider with ChangeNotifier {
  final ChatService _service = ChatService();

  bool isConnected = false;
  bool isLoadingUsers = false;

  final List<Map<String, dynamic>> users = [];

  int page = 1;
  bool hasMore = true;

  // ================= INIT =================

  Future<void> init(String token) async {
    if (!isConnected) {
      _service.connect(token);
    }

    _listenSocket();

    // Delay initial load safely
    await Future.delayed(Duration.zero);
    loadUsers(reset: true);
  }

  // ================= SOCKET =================

  bool _listenersAttached = false;

  void _listenSocket() {
    if (_listenersAttached) return;
    _listenersAttached = true;

    final socket = _service.socket;

    socket.onConnect((_) {
      isConnected = true;
      _safeNotify();
    });

    socket.onDisconnect((_) {
      isConnected = false;
      _safeNotify();
    });

    socket.on("usersList", (data) {
      _handleUsers(data);
    });

    socket.on("messages", (data) {
      if (_currentChatUserId == null) return;

      _messages.clear();
      for (var msg in data) {
        _messages.add(Map<String, dynamic>.from(msg));
      }

      _safeNotify();
    });

    socket.on("newMessage", (data) {
      final msg = Map<String, dynamic>.from(data);

      // only update if current chat
      if (msg["sender_id"] == _currentChatUserId ||
          msg["receiver_id"] == _currentChatUserId) {
        _messages.add(msg);
        _safeNotify();
      }
    });

    socket.on("messageDeleted", (data) {
      _messages.removeWhere((m) => m["id"] == data["messageId"]);
      _safeNotify();
    });
  }

  // ================= USERS =================

  void loadUsers({bool reset = false}) {
    if (isLoadingUsers || !hasMore) return;

    isLoadingUsers = true;
    _safeNotify();

    if (reset) {
      users.clear();
      page = 1;
      hasMore = true;
    }

    _service.getUsersList(page: page);
  }

  void _handleUsers(dynamic data) {
    final list = List<Map<String, dynamic>>.from(data["conversations"]);

    if (list.isEmpty) {
      hasMore = false;
    } else {
      for (var item in list) {
        final exists = users.any((u) => u["id"] == item["id"]);
        if (!exists) {
          users.add(item);
        }
      }

      page++;
    }

    isLoadingUsers = false;
    _safeNotify();
  }

  // ================= SAFE NOTIFY =================

  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.idle) {
      notifyListeners();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void disposeSocket() {
    _service.disconnect();
  }

  // ================= MESSAGES =================

  final List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => List.unmodifiable(_messages);

  int? _currentChatUserId;

  void openChat(int opponentId) {
    _currentChatUserId = opponentId;
    _messages.clear();
    _safeNotify();

    _service.getMessages(opponentId);
  }

  // send message
  void sendMessage({
    required int receiverId,
    required String message,
    int? studentId,
    int? typeId,
  }) {
    _service.sendMessage(
      receiverId: receiverId,
      message: message,
      type: "msg",
      studentId: studentId,
      typeId: typeId,
    );
  }

  // ================= STAFFS =================

  final List<StaffModel> _staffs = [];
  List<StaffModel> get staffs => _staffs;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMoreStaffs => _currentPage < _totalPages;

  bool _isFetchedOnce = false;
  bool _isLoadingStaffs = false;
  bool get isLoadingStaffs => _isLoadingStaffs;

  Future<void> fetchStaffsUnderSchool({
    bool loadMore = false,
    bool forceRefresh = false,
    String? query,
  }) async {
    if (_isLoadingStaffs) return;

    if (!loadMore && !forceRefresh && _isFetchedOnce && query == null) return;

    _isLoadingStaffs = true;

    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _staffs.clear();
        _isFetchedOnce = false;
      }

      final response = await ChatService().fetchStaffsUnderSchool(
        pageNo: _currentPage,
        query: query,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];
        final List staffsJson = data['staffs'];
        final List<StaffModel> fetchedStaffs =
            staffsJson
                .map((jsonItem) => StaffModel.fromJson(jsonItem))
                .toList();

        _staffs.addAll(fetchedStaffs);
        _isFetchedOnce = true;
      } else {
        throw Exception('Failed to fetch staff: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingStaffs = false;
      notifyListeners();
    }
  }
}
