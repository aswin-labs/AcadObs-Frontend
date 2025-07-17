import 'dart:convert';

SubjectModel subjectFromJson(String str) =>
    SubjectModel.fromJson(json.decode(str));

class SubjectModel {
  int id;
  String subjectName;
  String? classRange;
  int? schoolId;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;

  SubjectModel({
    required this.id,
    required this.subjectName,
    this.classRange,
    this.schoolId,
    this.trash,
    this.createdAt,
    this.updatedAt,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) => SubjectModel(
    id: json["id"],
    subjectName: json["subject_name"],
    classRange: json["class_range"],
    schoolId: json["school_id"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );
}
