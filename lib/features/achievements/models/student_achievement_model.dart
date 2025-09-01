import 'dart:convert';

StudentAchievementModel studentAchievementModelFromJson(String str) =>
    StudentAchievementModel.fromJson(json.decode(str));

String studentAchievementModelToJson(StudentAchievementModel data) =>
    json.encode(data.toJson());

class StudentAchievementModel {
  int? id;
  String? status;
  dynamic proofDocument;
  String? remarks;
  Achievement? achievement;

  StudentAchievementModel({
    this.id,
    this.status,
    this.proofDocument,
    this.remarks,
    this.achievement,
  });

  factory StudentAchievementModel.fromJson(Map<String, dynamic> json) =>
      StudentAchievementModel(
        id: json["id"],
        status: json["status"],
        proofDocument: json["proof_document"],
        remarks: json["remarks"],
        achievement:
            json["Achievement"] == null
                ? null
                : Achievement.fromJson(json["Achievement"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "status": status,
    "proof_document": proofDocument,
    "remarks": remarks,
    "Achievement": achievement?.toJson(),
  };
}

class Achievement {
  int? id;
  String? title;
  String? description;
  String? category;
  String? level;
  DateTime? date;

  Achievement({
    this.id,
    this.title,
    this.description,
    this.category,
    this.level,
    this.date,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    category: json["category"],
    level: json["level"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "category": category,
    "level": level,
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
  };
}
