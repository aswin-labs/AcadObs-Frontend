import 'dart:convert';

import 'package:acadobs/features/achievements/models/achievement_model.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';

StudentAchievementModel studentAchievementModelFromJson(String str) =>
    StudentAchievementModel.fromJson(json.decode(str));

class StudentAchievementModel {
  int? id;
  String? status;
  dynamic proofDocument;
  String? remarks;
  StudentModel? student;
  AchievementModel? achievement;

  StudentAchievementModel({
    this.id,
    this.status,
    this.proofDocument,
    this.remarks,
    this.student,
    this.achievement,
  });

  factory StudentAchievementModel.fromJson(Map<String, dynamic> json) =>
      StudentAchievementModel(
        id: json["id"],
        status: json["status"],
        proofDocument: json["proof_document"],
        remarks: json["remarks"],
        student:
            json["Student"] == null
                ? null
                : StudentModel.fromJson(json["Student"]),
        achievement:
            json["Achievement"] == null
                ? null
                : AchievementModel.fromJson(json["Achievement"]),
      );
}
