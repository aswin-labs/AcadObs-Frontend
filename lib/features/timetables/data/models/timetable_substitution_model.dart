import 'dart:convert';

import 'package:acadobs/features/timetables/data/models/timetable_model.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:acadobs/shared/models/user_model.dart';

TimetableSubstitutionModel timetableSubstitutionFromJson(String str) =>
    TimetableSubstitutionModel.fromJson(json.decode(str));

class TimetableSubstitutionModel {
  final int id;
  final int schoolId;
  final int timetableId;
  int? subStaffId;
  DateTime? date;
  int? subjectId;
  String? reason;
  DateTime? createdAt;
  DateTime? updatedAt;
  TimetableModel? timetable;
  UserModel? user;
  SubjectModel? subject;

  TimetableSubstitutionModel({
    required this.id,
    required this.schoolId,
    required this.timetableId,
    this.subStaffId,
    this.date,
    this.subjectId,
    this.reason,
    this.createdAt,
    this.updatedAt,
    this.timetable,
    this.user,
    this.subject,
  });

  factory TimetableSubstitutionModel.fromJson(
    Map<String, dynamic> json,
  ) => TimetableSubstitutionModel(
    id: json["id"],
    schoolId: json["school_id"],
    timetableId: json["timetable_id"],
    subStaffId: json["sub_staff_id"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    subjectId: json["subject_id"],
    reason: json["reason"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    timetable:
        json["Timetable"] == null
            ? null
            : TimetableModel.fromJson(json["Timetable"]),
    user: json["User"] == null ? null : UserModel.fromJson(json["User"]),
    subject:
        json["Subject"] == null ? null : SubjectModel.fromJson(json["Subject"]),
  );
}
