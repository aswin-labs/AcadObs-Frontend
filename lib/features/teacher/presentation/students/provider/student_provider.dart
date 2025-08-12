import 'dart:developer';

import 'package:acadobs/features/teacher/data/services/student_services.dart';
import 'package:acadobs/shared/models/student_model.dart';
import 'package:flutter/material.dart';

class StudentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  StudentModel? individualStudent;

  // Fetch Students by class id
  Future<void> fetchStudentsByClassId({required int classId}) async {
    _isLoading = true;
    _students.clear();
    notifyListeners();
    try {
      final response = await StudentServices().fetchStudentsByClassId(
        classId: classId,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final List studentsJson = data['students'] ?? [];
        final List<StudentModel> fetchedStudents =
            studentsJson
                .map((jsonItem) => StudentModel.fromJson(jsonItem))
                .toList();

        _students.addAll(fetchedStudents);
      } else {
        throw Exception('Failed to fetch staff duties: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // clear students
  void clearStudents() {
    _isLoading = false;
    _students.clear();
    individualStudent = null;
    notifyListeners();
  }

  // Get Individual student details
  Future<void> fetchStudentDetails({required int studentId}) async {
    _isLoading = true;
    try {
      final response = await StudentServices().fetchStudentDetails(
        studentId: studentId,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        individualStudent = StudentModel.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
