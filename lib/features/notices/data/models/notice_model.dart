import 'dart:convert';

NoticeModel noticesFromJson(String str) =>
    NoticeModel.fromJson(json.decode(str));

class NoticeModel {
  int id;
  int? schoolId;
  String? title;
  String? content;
  String? file;
  String? type;
  String date;
  bool? trash;
  DateTime createdAt;
  DateTime? updatedAt;
  List<dynamic>? noticeClasses;

  NoticeModel({
    required this.id,
    this.schoolId,
    this.title,
    this.content,
    this.file,
    this.type,
    required this.date,
    this.trash,
    required this.createdAt,
    this.updatedAt,
    this.noticeClasses,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) => NoticeModel(
    id: json["id"],
    schoolId: json["school_id"],
    title: json["title"],
    content: json["content"],
    file: json["file"] as String?,
    type: json["type"],
    date: json["date"],
    trash: json["trash"],
    createdAt: DateTime.parse(json["createdAt"]),

    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    noticeClasses:
        json["NoticeClasses"] == null
            ? []
            : List<dynamic>.from(json["NoticeClasses"]!.map((x) => x)),
  );
}
