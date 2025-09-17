import 'dart:convert';

import 'package:acadobs/features/marks/data/models/marks_model.dart';

StudentMarkModel studentMarkModelFromJson(String str) =>
    StudentMarkModel.fromJson(json.decode(str));

class StudentMarkModel {
  int? id;
  int? internalId;
  int? studentId;
  String? marksObtained;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  MarksModel? internalExam;

  StudentMarkModel({
    this.id,
    this.internalId,
    this.studentId,
    this.marksObtained,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.internalExam,
  });

  factory StudentMarkModel.fromJson(
    Map<String, dynamic> json,
  ) => StudentMarkModel(
    id: json["id"],
    internalId: json["internal_id"],
    studentId: json["student_id"],
    marksObtained: json["marks_obtained"],
    status: json["status"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    internalExam:
        json["InternalMark"] == null
            ? null
            : MarksModel.fromJson(json["InternalMark"]),
  );
}
