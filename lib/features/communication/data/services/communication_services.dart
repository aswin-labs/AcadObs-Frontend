import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class CommunicationServices {
  /// Create / send a message (POST /teacher/createMessage or /guardian/createMessage)
  Future<Response> createMessage({
    required bool forStaff,
    required int receiverId,
    required String message,
    int? studentId,
    int? replyToId,
    String? type,
    int? typeId,
  }) async {
    final endpoint =
        forStaff
            ? ApiEndpoints.teacherCreateMessage
            : ApiEndpoints.guardianCreateMessage;

    final payload = <String, dynamic>{
      "receiver_id": receiverId,
      "message": message.trim(),
      "student_id": studentId,
      "replyToId": replyToId,
      "type": type,
      "type_id": typeId,
    };

    return await ApiServices.post(endpoint, payload);
  }

  /// Fetch my communication threads (GET /teacher/getMyChats or /guardian/getMyChats)
  Future<Response> getMyChats({
    required bool forStaff,
    required int page,
    int? limit,
    String? query,
  }) async {
    final baseEndpoint =
        forStaff
            ? ApiEndpoints.teacherGetMyChats
            : ApiEndpoints.guardianGetMyChats;
    final effectiveLimit = limit ?? AppConstants.paginationLimit;

    String url = "$baseEndpoint?page=$page&limit=$effectiveLimit";
    if (query != null && query.trim().isNotEmpty) {
      url += "&q=${Uri.encodeQueryComponent(query.trim())}";
    }

    return await ApiServices.get(url);
  }

  /// Fetch messages for a specific chat thread (GET /teacher/getMessagesByChatId/:chat_id or /guardian/getMessagesByChatId/:chat_id)
  Future<Response> getMessagesByChatId({
    required bool forStaff,
    required int chatId,
    required int page,
    int? limit,
    String? query,
  }) async {
    final baseEndpoint =
        forStaff
            ? ApiEndpoints.teacherGetMessagesByChatId
            : ApiEndpoints.guardianGetMessagesByChatId;
    final effectiveLimit = limit ?? 15;

    String url = "$baseEndpoint/$chatId?page=$page&limit=$effectiveLimit";
    if (query != null && query.trim().isNotEmpty) {
      url += "&q=${Uri.encodeQueryComponent(query.trim())}";
    }

    return await ApiServices.get(url);
  }
}

