import 'package:acadobs/shared/models/student_model.dart';

class StudentHomeworkStatus {
    int? id;
    String? status;
    int? points;
    String? solvedFile;
    StudentModel? student;

    StudentHomeworkStatus({
        this.id,
        this.status,
        this.points,
        this.solvedFile,
        this.student,
    });

    factory StudentHomeworkStatus.fromJson(Map<String, dynamic> json) => StudentHomeworkStatus(
        id: json["id"],
        status: json["status"],
        points: json["points"],
        solvedFile: json["solved_file"],
        student: json["Student"] == null ? null : StudentModel.fromJson(json["Student"]),
    );

}