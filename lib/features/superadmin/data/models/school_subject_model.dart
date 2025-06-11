import 'dart:convert';

SchoolSubject schoolSubjectFromJson(String str) =>
    SchoolSubject.fromJson(json.decode(str));

String schoolSubjectToJson(SchoolSubject data) => json.encode(data.toJson());

class SchoolSubject {
  int id;
  String subjectName;
  String classRange;
  int? schoolId;
  bool trash;
  DateTime createdAt;
  DateTime updatedAt;

  SchoolSubject({
    required this.id,
    required this.subjectName,
    required this.classRange,
    this.schoolId,
    required this.trash,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchoolSubject.fromJson(Map<String, dynamic> json) => SchoolSubject(
        id: json["id"],
        subjectName: json["subject_name"],
        classRange: json["class_range"],
        schoolId: json["school_id"],
        trash: json["trash"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "subject_name": subjectName,
        "class_range": classRange,
        "school_id": schoolId,
        "trash": trash,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
