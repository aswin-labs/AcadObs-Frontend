import 'package:acadobs/features/students/data/models/student_model.dart';

class AttendanceStatusModel {
  int id;
  String status;
  String? remarks;
  StudentModel? student;
  AttendanceStatusModel({
    required this.id,
    required this.status,
    this.remarks,
    required this.student,
  });

  factory AttendanceStatusModel.fromJson(Map<String, dynamic> json) =>
      AttendanceStatusModel(
        id: json["id"],
        status: json["status"],
        remarks: json["remarks"],
        student:
            json["Student"] == null
                ? null
                : StudentModel.fromJson(json["Student"]),
      );
}
