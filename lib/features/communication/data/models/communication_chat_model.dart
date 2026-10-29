import 'package:acadobs/features/communication/data/models/communication_message_model.dart';

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString())?.toLocal();
}

class CommunicationUserModel {
  final int? id;
  final String? name;
  final String? phone;
  final String? dp;

  const CommunicationUserModel({
    this.id,
    this.name,
    this.phone,
    this.dp,
  });

  factory CommunicationUserModel.fromJson(Map<String, dynamic> json) {
    return CommunicationUserModel(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      dp: json['dp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'dp': dp,
  };
}

class CommunicationChatModel {
  final int? id;
  final CommunicationUserModel? user;
  final CommunicationMessageModel? message;
  final int unseenCount;
  final DateTime? updatedAt;

  const CommunicationChatModel({
    this.id,
    this.user,
    this.message,
    this.unseenCount = 0,
    this.updatedAt,
  });

  factory CommunicationChatModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'] ?? json['opponent'];
    final messageRaw = json['message'] ?? json['lastMessage'];
    return CommunicationChatModel(
      id: _parseInt(json['id']),
      user:
          userRaw is Map
              ? CommunicationUserModel.fromJson(
                Map<String, dynamic>.from(userRaw),
              )
              : null,
      message:
          messageRaw is Map
              ? CommunicationMessageModel.fromJson(
                Map<String, dynamic>.from(messageRaw),
              )
              : null,
      unseenCount:
          _parseInt(json['unseenCount'] ?? json['unseen_messages_count']) ?? 0,
      updatedAt: _parseDateTime(json['updatedAt']),
    );
  }

  CommunicationChatModel copyWith({
    int? id,
    CommunicationUserModel? user,
    CommunicationMessageModel? message,
    int? unseenCount,
    DateTime? updatedAt,
  }) {
    return CommunicationChatModel(
      id: id ?? this.id,
      user: user ?? this.user,
      message: message ?? this.message,
      unseenCount: unseenCount ?? this.unseenCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class CommunicationChatListResponse {
  final String? message;
  final int totalContent;
  final int currentPage;
  final int totalPages;
  final List<CommunicationChatModel> data;

  const CommunicationChatListResponse({
    this.message,
    this.totalContent = 0,
    this.currentPage = 1,
    this.totalPages = 1,
    this.data = const [],
  });

  factory CommunicationChatListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    return CommunicationChatListResponse(
      message: json['message']?.toString(),
      totalContent:
          _parseInt(json['totalContent'] ?? json['totalcontent']) ?? 0,
      currentPage: _parseInt(json['currentPage']) ?? 1,
      totalPages: _parseInt(json['totalPages']) ?? 1,
      data:
          rawList is List
              ? rawList
                  .whereType<Map>()
                  .map(
                    (e) => CommunicationChatModel.fromJson(
                      Map<String, dynamic>.from(e),
                    ),
                  )
                  .toList()
              : [],
    );
  }
}
