import 'package:acadobs/features/students/data/models/student_model.dart';

class AchievementSection {
  final String sectionId; // 👈 stable per-section key
  int? classId;
  StudentModel? selectedStudent;
  String? status;
  String? remark;

  AchievementSection({
    String? sectionId,
    this.classId,
    this.selectedStudent,
    this.status,
    this.remark,
  }) : sectionId = sectionId ?? DateTime.now().microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        "student_id": selectedStudent?.id,
        "status": status,
        "remarks": remark,
      };
}
