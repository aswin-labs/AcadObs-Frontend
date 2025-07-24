import 'dart:convert';

import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/models/subject_model.dart';

MarksModel marksModelFromJson(String str) =>
    MarksModel.fromJson(json.decode(str));

class MarksModel {
  int id;
  String internalName;
  String maxMarks;
  DateTime? date;
  List<StudentMark>? marks;
  School? school;
  ClassGradeModel? classGrade;
  SubjectModel? subject;

  MarksModel({
    required this.id,
    required this.internalName,
    required this.maxMarks,
    this.date,
    this.marks,
    this.school,
    this.classGrade,
    this.subject,
  });

  factory MarksModel.fromJson(Map<String, dynamic> json) => MarksModel(
    id: json["id"],
    internalName: json["internal_name"],
    maxMarks: json["max_marks"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    marks:
        json["Marks"] == null
            ? []
            : List<StudentMark>.from(
              json["Marks"]!.map((x) => StudentMark.fromJson(x)),
            ),
    school: json["School"] == null ? null : School.fromJson(json["School"]),
    classGrade:
        json["Class"] == null ? null : ClassGradeModel.fromJson(json["Class"]),
    subject:
        json["Subject"] == null ? null : SubjectModel.fromJson(json["Subject"]),
  );
}

class StudentMark {
  int? id;
  String? marksObtained;

  StudentMark({this.id, this.marksObtained});

  factory StudentMark.fromJson(Map<String, dynamic> json) =>
      StudentMark(id: json["id"], marksObtained: json["marks_obtained"]);

  Map<String, dynamic> toJson() => {"id": id, "marks_obtained": marksObtained};
}

class School {
  int? id;
  String? name;

  School({this.id, this.name});

  factory School.fromJson(Map<String, dynamic> json) =>
      School(id: json["id"], name: json["name"]);
}
