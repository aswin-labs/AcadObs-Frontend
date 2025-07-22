import 'dart:convert';

import 'package:acadobs/features/teacher/data/models/homework/student_homework_status.dart';

HomeworkModel homeworkModelFromJson(String str) => HomeworkModel.fromJson(json.decode(str));


class HomeworkModel {
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
    List<StudentHomeworkStatus>? studentHomeworkStatus;

    HomeworkModel({
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
        this.studentHomeworkStatus,
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
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        studentHomeworkStatus: json["HomeworkAssignments"] == null ? [] : List<StudentHomeworkStatus>.from(json["HomeworkAssignments"]!.map((x) => StudentHomeworkStatus.fromJson(x))),
    );
}

