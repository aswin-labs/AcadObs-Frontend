import 'dart:convert';

import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:acadobs/shared/models/user_model.dart';

MarksModel marksModelFromJson(String str) =>
    MarksModel.fromJson(json.decode(str));

class MarksModel {
  int id;
  String internalName;
  String? term;
  String maxMarks;
  DateTime? date;
  List<StudentMark>? studentMarks;
  School? school;
  ClassGradeModel? classGrade;
  SubjectModel? subject;
  TermExam? termExam;
  bool? forStaff;
  UserModel? user;
  int? examId;
  int? schoolId;
  int? classId;
  int? subjectId;
  int? recordedBy;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;

  bool get isTermExam => examId != null || termExam != null;
  bool get isInternalExam => !isTermExam;

  MarksModel({
    required this.id,
    required this.internalName,
    this.term,
    required this.maxMarks,
    this.date,
    this.studentMarks,
    this.school,
    this.classGrade,
    this.subject,
    this.termExam,
    this.user,
    this.examId,
    this.schoolId,
    this.classId,
    this.subjectId,
    this.recordedBy,
    this.trash,
    this.createdAt,
    this.updatedAt,
  });

  factory MarksModel.fromJson(Map<String, dynamic> json) => MarksModel(
    id: json["id"] ?? 0,
    internalName: json["internal_name"] ?? "",
    term: json["term"],
    maxMarks: json["max_marks"]?.toString() ?? "0",
    date: json["date"] == null ? null : DateTime.tryParse(json["date"].toString()),
    studentMarks:
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
    termExam: json["exam"] == null ? null : TermExam.fromJson(json["exam"]),
    user: json["User"] == null ? null : UserModel.fromJson(json["User"]),
    examId: json["exam_id"],
    schoolId: json["school_id"],
    classId: json["class_id"],
    subjectId: json["subject_id"],
    recordedBy: json["recorded_by"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null
            ? null
            : DateTime.tryParse(json["createdAt"].toString()),
    updatedAt:
        json["updatedAt"] == null
            ? null
            : DateTime.tryParse(json["updatedAt"].toString()),
  );
}

class StudentMark {
  int? id;
  String? marksObtained;
  String? status;
  StudentModel? student;

  StudentMark({this.id, this.marksObtained, this.status, this.student});

  factory StudentMark.fromJson(Map<String, dynamic> json) => StudentMark(
    id: json["id"],
    marksObtained: json["marks_obtained"],
    status: json["status"],
    student:
        json["Student"] == null ? null : StudentModel.fromJson(json["Student"]),
  );
}

class School {
  int? id;
  String? name;

  School({this.id, this.name});

  factory School.fromJson(Map<String, dynamic> json) =>
      School(id: json["id"], name: json["name"]);
}

class TermExam {
  int? id;
  String? examName;
  String? educationYear;

  TermExam({this.id, this.examName, this.educationYear});

  factory TermExam.fromJson(Map<String, dynamic> json) => TermExam(
    id: json["id"],
    examName: json["exam_name"],
    educationYear: json["education_year"],
  );
}
