import 'dart:convert';

import 'package:acadobs/features/homework/data/models/homework_model.dart';

StudentHomeworkModel studentHomeworkModelFromJson(String str) => StudentHomeworkModel.fromJson(json.decode(str));

class StudentHomeworkModel {
    int? id;
    int? homeworkId;
    int? studentId;
    String? status;
    int? points;
    dynamic solvedFile;
    DateTime? createdAt;
    DateTime? updatedAt;
    HomeworkModel? homework;

    StudentHomeworkModel({
        this.id,
        this.homeworkId,
        this.studentId,
        this.status,
        this.points,
        this.solvedFile,
        this.createdAt,
        this.updatedAt,
        this.homework,
    });

    factory StudentHomeworkModel.fromJson(Map<String, dynamic> json) => StudentHomeworkModel(
        id: json["id"],
        homeworkId: json["homework_id"],
        studentId: json["student_id"],
        status: json["status"],
        points: json["points"],
        solvedFile: json["solved_file"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        homework: json["Homework"] == null ? null : HomeworkModel.fromJson(json["Homework"]),
    );

   
}



