import 'dart:convert';

import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:acadobs/shared/models/user_model.dart';

TimetableModel timetableFromJson(String str) =>
    TimetableModel.fromJson(json.decode(str));

class TimetableModel {
  final int id;
  int? schoolId;
  int? classId;
  int? dayOfWeek;
  int? periodNumber;
  int? subjectId;
  int? staffId;
  DateTime? createdAt;
  DateTime? updatedAt;
  UserModel? user;
  SubjectModel? subject;
  ClassGradeModel? classGrade;

  TimetableModel({
    required this.id,
    this.schoolId,
    this.classId,
    this.dayOfWeek,
    this.periodNumber,
    this.subjectId,
    this.staffId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.subject,
    this.classGrade,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) => TimetableModel(
    id: json["id"] as int,
    schoolId: json["school_id"] as int?,
    classId: json["class_id"] as int?,
    dayOfWeek: json["day_of_week"] as int?,
    periodNumber: json["period_number"] as int?,
    subjectId: json["subject_id"] as int?,
    staffId: json["staff_id"] as int?,
    createdAt:
        json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"] as String),
    updatedAt:
        json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"] as String),
    user:
        json["User"] == null
            ? null
            : UserModel.fromJson(Map<String, dynamic>.from(json["User"])),
    subject:
        json["Subject"] == null
            ? null
            : SubjectModel.fromJson(Map<String, dynamic>.from(json["Subject"])),
    classGrade:
        json["Class"] == null
            ? null
            : ClassGradeModel.fromJson(
              Map<String, dynamic>.from(json["Class"]),
            ),
  );
}
