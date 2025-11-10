import 'dart:convert';

import 'package:acadobs/features/achievements/models/student_achievement_model.dart';

AchievementModel achievementModelFromJson(String str) =>
    AchievementModel.fromJson(json.decode(str));

class AchievementModel {
  int? id;
  int? schoolId;
  String? title;
  String? description;
  String? category;
  String? level;
  DateTime? date;
  String? awardingBody;
  int? recordedBy;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<StudentAchievementModel>? studentAchievements;

  AchievementModel({
    this.id,
    this.schoolId,
    this.title,
    this.description,
    this.category,
    this.level,
    this.date,
    this.awardingBody,
    this.recordedBy,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.studentAchievements,
  });

  factory AchievementModel.fromJson(
    Map<String, dynamic> json,
  ) => AchievementModel(
    id: json["id"],
    schoolId: json["school_id"],
    title: json["title"],
    description: json["description"],
    category: json["category"],
    level: json["level"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    awardingBody: json["awarding_body"],
    recordedBy: json["recorded_by"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    studentAchievements:
        json["StudentAchievements"] == null
            ? []
            : List<StudentAchievementModel>.from(
              json["StudentAchievements"]!.map(
                (x) => StudentAchievementModel.fromJson(x),
              ),
            ),
  );
}
