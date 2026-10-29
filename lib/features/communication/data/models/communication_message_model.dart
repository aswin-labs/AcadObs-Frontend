import 'package:acadobs/features/communication/data/models/communication_chat_model.dart';

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

class CommunicationSenderModel {
  final int? id;
  final String? name;

  const CommunicationSenderModel({this.id, this.name});

  factory CommunicationSenderModel.fromJson(Map<String, dynamic> json) {
    return CommunicationSenderModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
    );
  }
}

class CommunicationMessageModel {
  final int? id;
  final int? chatId;
  final String? message;
  final int? senderId;
  final int? receiverId;
  final String? status;
  final String? type;
  final int? typeId;
  final int? replyToId;
  final int? studentId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final CommunicationSenderModel? sender;
  final Map<String, dynamic>? typeData;

  const CommunicationMessageModel({
    this.id,
    this.chatId,
    this.message,
    this.senderId,
    this.receiverId,
    this.status,
    this.type,
    this.typeId,
    this.replyToId,
    this.studentId,
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.typeData,
  });

  factory CommunicationMessageModel.fromJson(Map<String, dynamic> json) {
    final senderRaw = json['sender'];
    final parsedSender =
        senderRaw is Map
            ? CommunicationSenderModel.fromJson(
              Map<String, dynamic>.from(senderRaw),
            )
            : null;
    return CommunicationMessageModel(
      id: _parseInt(json['id']),
      chatId: _parseInt(json['chat_id']),
      message: json['message']?.toString(),
      senderId: _parseInt(json['sender_id']) ?? parsedSender?.id,
      receiverId: _parseInt(json['receiver_id']),
      status: json['status']?.toString(),
      type: json['type']?.toString(),
      typeId: _parseInt(json['type_id']),
      replyToId: _parseInt(json['replyToId']),
      studentId: _parseInt(json['student_id']),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      sender: parsedSender,
      typeData:
          json['typeData'] is Map
              ? Map<String, dynamic>.from(json['typeData'] as Map)
              : null,
    );
  }

  /// Extracts a human-readable context title if this message references a specific module item
  String? get contextTitle {
    if (type == null || type!.trim().isEmpty || type == 'msg') return null;
    final cleanType = type!.trim();
    switch (cleanType.toLowerCase()) {
      case 'homework':
        return 'Homework';
      case 'parentnote':
      case 'parent_note':
        return 'Parent Note';
      case 'achievement':
        return 'Achievement';
      case 'internalmark':
      case 'internal_mark':
        return 'Internal Mark';
      case 'payment':
        return 'Payment';
      case 'attendance':
        return 'Attendance';
      case 'notice':
        return 'Notice';
      case 'invoice':
        return 'Invoice';
      default:
        return cleanType;
    }
  }

  /// Extracts a human-readable context subtitle/description from `typeData`
  String? get contextSubtitle {
    if (typeData == null || typeData!.isEmpty) return null;
    final candidates = [
      typeData!['title'],
      typeData!['note_title'],
      typeData!['achievement_title'],
      typeData!['notice_title'],
      typeData!['invoice_no'],
      typeData!['description'],
      typeData!['note_content'],
      typeData!['remarks'],
      typeData!['amount'] != null ? 'Amount: ₹${typeData!['amount']}' : null,
      typeData!['date'],
    ];

    for (final item in candidates) {
      if (item != null && item.toString().trim().isNotEmpty) {
        return item.toString().trim();
      }
    }
    return null;
  }
}

class CommunicationMessagesResponse {
  final String? message;
  final int totalContent;
  final int currentPage;
  final int totalPages;
  final CommunicationUserModel? opponent;
  final List<CommunicationMessageModel> data;

  const CommunicationMessagesResponse({
    this.message,
    this.totalContent = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.opponent,
    this.data = const [],
  });

  factory CommunicationMessagesResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final opponentRaw = json['opponent'] ?? json['user'];
    return CommunicationMessagesResponse(
      message: json['message']?.toString(),
      totalContent:
          _parseInt(json['totalContent'] ?? json['totalcontent']) ?? 0,
      currentPage: _parseInt(json['currentPage']) ?? 1,
      totalPages: _parseInt(json['totalPages']) ?? 1,
      opponent:
          opponentRaw is Map
              ? CommunicationUserModel.fromJson(
                Map<String, dynamic>.from(opponentRaw),
              )
              : null,
      data:
          rawList is List
              ? rawList
                  .whereType<Map>()
                  .map(
                    (e) => CommunicationMessageModel.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList()
              : [],
    );
  }
}
