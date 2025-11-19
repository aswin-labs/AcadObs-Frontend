import 'dart:convert';

import 'package:acadobs/features/homework/data/models/student_homework_status.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:acadobs/shared/models/user_model.dart';

HomeworkModel homeworkModelFromJson(String str) =>
    HomeworkModel.fromJson(json.decode(str));

class HomeworkModel {
  bool? forStudent;
  bool? forStaff;
  int? studentHomeworkId;
  int? guardianIdForChat;
  String? guardianNameForChat;
  String? studentStatus;
  int? studentPoints;
  int? id;
  int? schoolId;
  int? teacherId;
  int? classId;
  int? subjectId;
  String? title;
  String? description;
  DateTime? dueDate;
  String? file;
  String? type;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;
  UserModel? user;
  List<StudentHomeworkStatus>? studentHomeworkStatus;
  SubjectModel? subject;
  ClassGradeModel? classGrade;

  HomeworkModel({
    this.forStudent = false,
    this.forStaff = false,
    this.studentHomeworkId = 0,
    this.guardianIdForChat = 0,
    this.guardianNameForChat = "",
    this.studentStatus = "N/A",
    this.studentPoints = 0,
    this.id,
    this.schoolId,
    this.teacherId,
    this.classId,
    this.subjectId,
    this.title,
    this.description,
    this.dueDate,
    this.file,
    this.type,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.studentHomeworkStatus,
    this.subject,
    this.classGrade,
  });

  factory HomeworkModel.fromJson(Map<String, dynamic> json) => HomeworkModel(
    id: json["id"],
    schoolId: json["school_id"],
    teacherId: json["teacher_id"],
    classId: json["class_id"],
    subjectId: json["subject_id"],
    title: json["title"],
    description: json["description"],
    dueDate: json["due_date"] == null ? null : DateTime.parse(json["due_date"]),
    file: json["file"],
    type: json["type"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    user: json["User"] == null ? null : UserModel.fromJson(json["User"]),

    studentHomeworkStatus:
        json["HomeworkAssignments"] == null
            ? []
            : List<StudentHomeworkStatus>.from(
              json["HomeworkAssignments"]!.map(
                (x) => StudentHomeworkStatus.fromJson(x),
              ),
            ),
    subject:
        json["Subject"] == null ? null : SubjectModel.fromJson(json["Subject"]),
    classGrade:
        json["Class"] == null ? null : ClassGradeModel.fromJson(json["Class"]),
  );
}
