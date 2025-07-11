import 'dart:convert';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_status_model.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:acadobs/shared/models/user_model.dart';

AttendanceModel attendanceByTeacherFromJson(String str) =>
    AttendanceModel.fromJson(json.decode(str));

class AttendanceModel {
  int id;
  int period;
  DateTime date;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;
  ClassGradeModel? classDetails;
  SubjectModel? subject;
  UserModel? user;
  List<AttendanceStatusModel>? studentRecords;

  AttendanceModel({
    required this.id,
    required this.period,
    required this.date,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.classDetails,
    this.subject,
    this.user,
    this.studentRecords,
  });

  factory AttendanceModel.fromJson(
    Map<String, dynamic> json,
  ) => AttendanceModel(
    id: json["id"],
    period: json["period"],
    date: DateTime.parse(json["date"]),
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    classDetails:
        json["Class"] == null ? null : ClassGradeModel.fromJson(json["Class"]),
    subject:
        json["Subject"] == null ? null : SubjectModel.fromJson(json["Subject"]),
    user: json["User"] == null ? null : UserModel.fromJson(json["User"]),
    studentRecords:
        json["AttendanceMarkeds"] == null
            ? []
            : List<AttendanceStatusModel>.from(
              json["AttendanceMarkeds"]!.map(
                (x) => AttendanceStatusModel.fromJson(x),
              ),
            ),
  );
}
