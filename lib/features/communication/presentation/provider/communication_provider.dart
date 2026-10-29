import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/communication/data/models/communication_chat_model.dart';
import 'package:acadobs/features/communication/data/models/communication_message_model.dart';
import 'package:acadobs/features/communication/data/services/communication_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CommunicationProvider extends ChangeNotifier {
  final CommunicationServices _services = CommunicationServices();

  // ===================== CHATS LIST STATE =====================
  List<CommunicationChatModel> _chats = [];
  List<CommunicationChatModel> get chats => _chats;

  bool _isLoadingChats = false;
  bool get isLoadingChats => _isLoadingChats;

  bool _isLoadingMoreChats = false;
  bool get isLoadingMoreChats => _isLoadingMoreChats;

  bool _hasMoreChats = true;
  bool get hasMoreChats => _hasMoreChats;

  int _currentChatPage = 1;
  int get currentChatPage => _currentChatPage;

  int _totalChatPages = 1;
  int get totalChatPages => _totalChatPages;

  int _totalChatContent = 0;
  int get totalChatContent => _totalChatContent;

  String? _currentChatQuery;
  bool _hasFetchedChatsOnce = false;

  int get totalUnseenMessagesCount =>
      _chats.fold(0, (sum, item) => sum + item.unseenCount);

  // ===================== MESSAGES DETAIL STATE =====================
  List<CommunicationMessageModel> _messages = [];
  List<CommunicationMessageModel> get messages => _messages;

  CommunicationUserModel? _activeOpponent;
  CommunicationUserModel? get activeOpponent => _activeOpponent;

  int? _activeChatId;
  int? get activeChatId => _activeChatId;

  bool _isLoadingMessages = false;
  bool get isLoadingMessages => _isLoadingMessages;

  bool _isLoadingMoreMessages = false;
  bool get isLoadingMoreMessages => _isLoadingMoreMessages;

  bool _hasMoreMessages = true;
  bool get hasMoreMessages => _hasMoreMessages;

  int _currentMessagePage = 1;
  int get currentMessagePage => _currentMessagePage;

  int _totalMessagePages = 1;
  int get totalMessagePages => _totalMessagePages;

  int _totalMessageContent = 0;
  int get totalMessageContent => _totalMessageContent;

  String? _currentMessageQuery;

  bool _isSendingMessage = false;
  bool get isSendingMessage => _isSendingMessage;

  String? _error;
  String? get error => _error;

  String _getFriendlyErrorMessage(Object error, String fallback) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final msg = data['message']?.toString() ?? data['error']?.toString();
        if (msg != null &&
            msg.trim().isNotEmpty &&
            !msg.toLowerCase().contains('dioexception') &&
            !msg.toLowerCase().contains('sequelize')) {
          return msg.trim();
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Request timed out. Please check your internet connection.";
        case DioExceptionType.connectionError:
          return "No internet connection. Please check your network.";
        default:
          break;
      }
    }
    return fallback;
  }

  /// Reset active thread state before opening a new thread
  void prepareConversation({
    int? chatId,
    CommunicationUserModel? opponent,
  }) {
    _activeChatId = chatId;
    _activeOpponent = opponent;
    _messages = [];
    _currentMessagePage = 1;
    _totalMessagePages = 1;
    _totalMessageContent = 0;
    _hasMoreMessages = true;
    _currentMessageQuery = null;
    _isLoadingMessages = chatId != null;
    _isLoadingMoreMessages = false;
    _error = null;
    notifyListeners();
  }

  /// Fetch paginated list of communication threads
  Future<void> fetchMyChats({
    required bool forStaff,
    bool forceRefresh = false,
    bool loadMore = false,
    bool silent = false,
    String? query,
  }) async {
    if (loadMore) {
      if (_isLoadingChats || _isLoadingMoreChats || !_hasMoreChats) return;
    } else if (_isLoadingChats && !silent && !forceRefresh) {
      return;
    }

    if (query != null) {
      _currentChatQuery = query.trim().isEmpty ? null : query.trim();
    }

    final int effectiveLimit = AppConstants.paginationLimit;
    final int targetPage =
        forceRefresh ? 1 : (loadMore ? (_currentChatPage + 1) : 1);

    if (loadMore) {
      _isLoadingMoreChats = true;
      notifyListeners();
    } else if (!silent) {
      _isLoadingChats = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await _services.getMyChats(
        forStaff: forStaff,
        page: targetPage,
        limit: effectiveLimit,
        query: _currentChatQuery,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final parsed = CommunicationChatListResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        final fetched = parsed.data;

        _totalChatContent = parsed.totalContent;
        _currentChatPage =
            parsed.currentPage > 0 ? parsed.currentPage : targetPage;
        _totalChatPages =
            parsed.totalPages > 0
                ? parsed.totalPages
                : (_totalChatContent > 0
                    ? (_totalChatContent / effectiveLimit).ceil()
                    : 1);
        _hasFetchedChatsOnce = true;

        if (targetPage == 1) {
          _chats = fetched;
          _hasMoreChats =
              fetched.isNotEmpty &&
              (_currentChatPage < _totalChatPages ||
                  (_totalChatContent > 0 && _chats.length < _totalChatContent));
        } else {
          final existingIds = _chats.map((e) => e.id).toSet();
          final newChats =
              fetched.where((e) => !existingIds.contains(e.id)).toList();
          if (newChats.isEmpty) {
            _hasMoreChats = false;
          } else {
            _chats.addAll(newChats);
            _hasMoreChats =
                _currentChatPage < _totalChatPages ||
                (_totalChatContent > 0 && _chats.length < _totalChatContent);
          }
        }
      } else {
        if (loadMore) _hasMoreChats = false;
      }
    } catch (e) {
      log("Error fetching communication chats: $e");
      if (loadMore) _hasMoreChats = false;
      if (!silent) {
        _error = _getFriendlyErrorMessage(
          e,
          "Unable to load conversations. Please try again.",
        );
      }
    } finally {
      _isLoadingChats = false;
      _isLoadingMoreChats = false;
      notifyListeners();
    }
  }

  /// Update search query for chats list
  Future<void> searchChats({
    required bool forStaff,
    required String query,
  }) async {
    _currentChatQuery = query.trim().isEmpty ? null : query.trim();
    await fetchMyChats(
      forStaff: forStaff,
      forceRefresh: true,
      query: _currentChatQuery ?? '',
    );
  }

  /// Find an existing chatId with a specific user (`receiverId`), if one exists
  Future<int?> resolveExistingChatId({
    required bool forStaff,
    required int receiverId,
  }) async {
    for (final chat in _chats) {
      if (chat.user?.id == receiverId && chat.id != null) {
        return chat.id;
      }
    }

    if (!_hasFetchedChatsOnce) {
      await fetchMyChats(forStaff: forStaff, forceRefresh: true, silent: true);
      for (final chat in _chats) {
        if (chat.user?.id == receiverId && chat.id != null) {
          return chat.id;
        }
      }
    }

    return null;
  }

  /// Fetch messages for a specific chatId with pagination and search support
  Future<void> fetchMessagesByChatId({
    required bool forStaff,
    required int chatId,
    bool forceRefresh = false,
    bool loadMore = false,
    bool silent = false,
    String? query,
  }) async {
    if (loadMore) {
      if (_isLoadingMessages || _isLoadingMoreMessages || !_hasMoreMessages) {
        return;
      }
    } else if (_isLoadingMessages && !silent && !forceRefresh) {
      return;
    }

    _activeChatId = chatId;
    if (query != null) {
      _currentMessageQuery = query.trim().isEmpty ? null : query.trim();
    }

    const int effectiveLimit = 15;
    final int targetPage =
        forceRefresh ? 1 : (loadMore ? (_currentMessagePage + 1) : 1);

    if (loadMore) {
      _isLoadingMoreMessages = true;
      notifyListeners();
    } else if (!silent) {
      _isLoadingMessages = true;
      _error = null;
      notifyListeners();
    }

    try {
      final response = await _services.getMessagesByChatId(
        forStaff: forStaff,
        chatId: chatId,
        page: targetPage,
        limit: effectiveLimit,
        query: _currentMessageQuery,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final parsed = CommunicationMessagesResponse.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
        final fetched = parsed.data;

        if (parsed.opponent != null) {
          _activeOpponent = parsed.opponent;
        }

        _totalMessageContent = parsed.totalContent;
        _currentMessagePage =
            parsed.currentPage > 0 ? parsed.currentPage : targetPage;
        _totalMessagePages =
            parsed.totalPages > 0
                ? parsed.totalPages
                : (_totalMessageContent > 0
                    ? (_totalMessageContent / effectiveLimit).ceil()
                    : 1);

        if (targetPage == 1) {
          _messages = fetched;
          _hasMoreMessages =
              fetched.isNotEmpty &&
              (_currentMessagePage < _totalMessagePages ||
                  (_totalMessageContent > 0 &&
                      _messages.length < _totalMessageContent));
        } else {
          final existingIds = _messages.map((e) => e.id).toSet();
          final newMsgs =
              fetched.where((e) => !existingIds.contains(e.id)).toList();
          if (newMsgs.isEmpty) {
            _hasMoreMessages = false;
          } else {
            _messages.addAll(newMsgs);
            _hasMoreMessages =
                _currentMessagePage < _totalMessagePages ||
                (_totalMessageContent > 0 &&
                    _messages.length < _totalMessageContent);
          }
        }

        // Mark unseenCount as 0 locally for this chat since backend marks messages as read
        final chatIdx = _chats.indexWhere((c) => c.id == chatId);
        if (chatIdx != -1 && _chats[chatIdx].unseenCount > 0) {
          _chats[chatIdx] = _chats[chatIdx].copyWith(unseenCount: 0);
        }
      } else {
        if (loadMore) _hasMoreMessages = false;
      }
    } catch (e) {
      log("Error fetching communication messages: $e");
      if (loadMore) _hasMoreMessages = false;
      if (!silent) {
        _error = _getFriendlyErrorMessage(
          e,
          "Unable to load messages. Please try again.",
        );
      }
    } finally {
      _isLoadingMessages = false;
      _isLoadingMoreMessages = false;
      notifyListeners();
    }
  }

  /// Send a new message via POST /createMessage and seamlessly update the thread without shimmer
  Future<int?> sendMessage({
    required BuildContext context,
    required bool forStaff,
    required int receiverId,
    required String message,
    int? chatId,
    int? studentId,
    int? replyToId,
    String? type,
    int? typeId,
  }) async {
    if (_isSendingMessage || message.trim().isEmpty) return null;

    _isSendingMessage = true;
    notifyListeners();

    try {
      final response = await _services.createMessage(
        forStaff: forStaff,
        receiverId: receiverId,
        message: message.trim(),
        studentId: studentId,
        replyToId: replyToId,
        type: type,
        typeId: typeId,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final rawData = response.data;
        final msgData =
            rawData is Map && rawData['data'] is Map
                ? Map<String, dynamic>.from(rawData['data'] as Map)
                : null;

        final createdMessage =
            msgData != null
                ? CommunicationMessageModel.fromJson(msgData)
                : null;
        final resolvedChatId =
            createdMessage?.chatId ?? chatId ?? _activeChatId;

        // Immediately insert the newly created message so there is zero UI flash or shimmer
        if (createdMessage != null) {
          final existingIndex = _messages.indexWhere(
            (m) => m.id != null && m.id == createdMessage.id,
          );
          if (existingIndex == -1) {
            _messages = [createdMessage, ..._messages];
            _totalMessageContent += 1;
          }
          notifyListeners();
        }

        if (resolvedChatId != null) {
          _activeChatId = resolvedChatId;
          // Silently sync in the background to populate any enriched fields (sender object, typeData, etc.)
          await fetchMessagesByChatId(
            forStaff: forStaff,
            chatId: resolvedChatId,
            forceRefresh: true,
            silent: true,
          );
        }

        // Refresh chat list silently in background so last_message & ordering stay fresh
        fetchMyChats(forStaff: forStaff, forceRefresh: true, silent: true);
        return resolvedChatId;
      } else {
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: "Unable to send message. Please try again.",
            type: SnackbarType.failure,
          );
        }
        return null;
      }
    } catch (e) {
      log("Error sending communication message: $e");
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: _getFriendlyErrorMessage(
            e,
            "Unable to send message. Please try again.",
          ),
          type: SnackbarType.failure,
        );
      }
      return null;
    } finally {
      _isSendingMessage = false;
      notifyListeners();
    }
  }
}
