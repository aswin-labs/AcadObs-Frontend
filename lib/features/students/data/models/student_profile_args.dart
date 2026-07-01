import 'package:acadobs/features/students/data/models/student_model.dart';

class StudentProfileArgs {
  final StudentModel student;
  final bool forStaff;

  const StudentProfileArgs({required this.student, required this.forStaff});
}
