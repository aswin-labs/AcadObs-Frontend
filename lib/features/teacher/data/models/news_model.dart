import 'dart:convert';

News newsFromJson(String str) => News.fromJson(json.decode(str));

String newsToJson(News data) => json.encode(data.toJson());

class News {
  int? id;
  int? schoolId;
  String title;
  String content;
  DateTime date;
  int? userId;
  String? file;
  bool? trash;
  DateTime createdAt;
  DateTime? updatedAt;

  News({
    this.id,
    this.schoolId,
    required this.title,
    required this.content,
    required this.date,
    this.userId,
    this.file,
    this.trash,
   required this.createdAt,
    this.updatedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) => News(
    id: json["id"],
    schoolId: json["school_id"],
    title: json["title"] ?? "",
    content: json["content"] ?? '',
    // date: json["date"] == null ? null : DateTime.parse(json["date"]),
    date: json["date"] == null ? DateTime.now() : DateTime.parse(json["date"]),
    userId: json["user_id"],
    file: json["file"],
    trash: json["trash"],
    // createdAt: DateTime.parse(json["createdAt"]),
    // createdAt:
    //     json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    createdAt:
        json["createdAt"] != null && json["createdAt"].toString().isNotEmpty
            ? DateTime.parse(json["createdAt"])
            : json["date"] != null
            ? DateTime.parse(json["date"])
            : DateTime.now(),

    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "school_id": schoolId,
    "title": title,
    "content": content,
    // "date":
    //     "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "date":
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "user_id": userId,
    "file": file,
    "trash": trash,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
