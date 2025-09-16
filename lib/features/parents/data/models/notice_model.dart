import 'dart:convert';

Notices noticesFromJson(String str) => Notices.fromJson(json.decode(str));

class Notices {
  int id;
  int? schoolId;
  String? title;
  String? content;
  // dynamic file;
  String? file;
  String? type;
  String date;
  bool? trash;
  DateTime createdAt;
  DateTime? updatedAt;
  List<dynamic>? noticeClasses;

  Notices({
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

  factory Notices.fromJson(Map<String, dynamic> json) => Notices(
    id: json["id"],
    schoolId: json["school_id"],
    title: json["title"],
    content: json["content"],
    file: json["file"] as String?, //changes
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
