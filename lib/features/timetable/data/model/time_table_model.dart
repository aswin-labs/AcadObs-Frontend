import 'dart:convert';

import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:acadobs/shared/models/user_model.dart';

TimeTableModel timeTableModelFromJson(String str) =>
    TimeTableModel.fromJson(json.decode(str));

class TimeTableModel {
  int? id;
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

  TimeTableModel({
    this.id,
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

  factory TimeTableModel.fromJson(Map<String, dynamic> json) => TimeTableModel(
    id: json["id"],
    schoolId: json["school_id"],
    classId: json["class_id"],
    dayOfWeek: json["day_of_week"],
    periodNumber: json["period_number"],
    subjectId: json["subject_id"],
    staffId: json["staff_id"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    user: json["User"] == null ? null : UserModel.fromJson(json["User"]),
    subject:
        json["Subject"] == null ? null : SubjectModel.fromJson(json["Subject"]),
    classGrade:
        json["Class"] == null ? null : ClassGradeModel.fromJson(json["Class"]),
  );
}

class Substitution {
  int? id;
  int? schoolId;
  int? timetableId;
  int? subStaffId;
  DateTime? date;
  int? subjectId;
  String? reason;
  DateTime? createdAt;
  DateTime? updatedAt;
  TimeTableModel? timeTable;
  UserModel? user;
  ClassGradeModel? classGrade;

  SubjectModel? subject;

  Substitution({
    this.id,
    this.createdAt,
    this.date,
    this.reason,
    this.schoolId,
    this.subStaffId,
    this.subjectId,
    this.timetableId,
    this.updatedAt,
    this.classGrade,
    this.subject,
    this.timeTable,
    this.user,
  });

  factory Substitution.fromJson(Map<String, dynamic> json) => Substitution(
    id: json["id"],
    schoolId: json["school_id"],
    timetableId: json["timetable_id"],
    subjectId: json["subject_id"],
    subStaffId: json["sub_staff_id"],
    reason: json["reason"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    timeTable:
        json["Timetable"] == null
            ? null
            : TimeTableModel.fromJson(json["Timetable"]),
    user: json["User"] == null ? null : UserModel.fromJson(json["User"]),
    subject:
        json["Subject"] == null ? null : SubjectModel.fromJson(json["Subject"]),
    classGrade:
        json["Class"] == null ? null : ClassGradeModel.fromJson(json["Class"]),
  );
}
