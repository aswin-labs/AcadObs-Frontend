class ChatModel {
  final int opponentId;
  final String opponentName;
  final int? studentId;
  final String? msgType;
  final int? typeId;
  String? title;
  String? subtitle;
  ChatModel({
    required this.opponentId,
    required this.opponentName,
    this.studentId,
    this.title,
    this.subtitle,
    this.msgType,
    this.typeId,
  });
}
