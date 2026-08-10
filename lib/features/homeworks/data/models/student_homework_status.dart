import 'package:acadobs/features/students/data/models/student_model.dart';

class StudentHomeworkStatus {
  int? id;
  String? remark;
  int? points;
  String? solvedFile;
  StudentModel? student;

  StudentHomeworkStatus({
    this.id,
    this.remark,
    this.points,
    this.solvedFile,
    this.student,
  });

  factory StudentHomeworkStatus.fromJson(Map<String, dynamic> json) =>
      StudentHomeworkStatus(
        id: json["id"],
        remark: json["remarks"],
        points: json["points"],
        solvedFile: json["solved_file"],
        student:
            json["Student"] == null
                ? null
                : StudentModel.fromJson(json["Student"]),
      );
}
