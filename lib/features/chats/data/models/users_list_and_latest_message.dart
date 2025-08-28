import 'dart:convert';

UsersListAndLatestMessage usersListAndLatestMessageFromJson(String str) =>
    UsersListAndLatestMessage.fromJson(json.decode(str));

class UsersListAndLatestMessage {
  int? chatId;
  String? lastMessage;
  DateTime? updatedAt;
  int? unreadCount;
  Opponent? opponent;

  UsersListAndLatestMessage({
    this.chatId,
    this.lastMessage,
    this.updatedAt,
    this.unreadCount,
    this.opponent,
  });

  factory UsersListAndLatestMessage.fromJson(
    Map<String, dynamic> json,
  ) => UsersListAndLatestMessage(
    chatId: json["chat_id"],
    lastMessage: json["last_message"],
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    unreadCount: json["unread_count"],
    opponent:
        json["opponent"] == null ? null : Opponent.fromJson(json["opponent"]),
  );
}

class Opponent {
  int? id;
  String? name;
  dynamic dp;

  Opponent({this.id, this.name, this.dp});

  factory Opponent.fromJson(Map<String, dynamic> json) =>
      Opponent(id: json["id"], name: json["name"], dp: json["dp"]);
}
