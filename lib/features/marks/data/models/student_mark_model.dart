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
    marksObtained: json["marks_obtained"]?.toString(),
    status: json["status"],
    createdAt:
        json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"].toString()),
    updatedAt:
        json["updatedAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"].toString()),
    internalExam:
        json["InternalMark"] == null
            ? null
            : MarksModel.fromJson(json["InternalMark"]),
  );

  bool get isAbsent => status?.toLowerCase() == 'absent';
  bool get isPresent => status?.toLowerCase() == 'present';

  double get obtainedMarks => double.tryParse(marksObtained ?? '') ?? 0.0;
  double get maxMarks =>
      double.tryParse(internalExam?.maxMarks ?? '') ?? 0.0;
  double get percentage =>
      maxMarks > 0 ? (obtainedMarks / maxMarks) * 100 : 0.0;

  bool get isTermExam => internalExam?.isTermExam ?? false;

  String get examDisplayTitle {
    final examName = internalExam?.termExam?.examName?.trim();
    final internalName = internalExam?.internalName.trim();
    if (examName != null && examName.isNotEmpty) {
      if (internalName != null && internalName.isNotEmpty) {
        return '$examName - $internalName';
      }
      return examName;
    }
    return (internalName != null && internalName.isNotEmpty)
        ? internalName
        : 'Assessment';
  }
}
