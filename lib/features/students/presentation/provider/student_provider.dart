import 'dart:developer';

import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/data/services/student_services.dart';
import 'package:flutter/material.dart';

class StudentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  Set<int> _selectedStudentIds = {};
  bool get isAllSelected =>
      _students.isNotEmpty && _selectedStudentIds.length == _students.length;
  Set<int> get selectedStudentIds => _selectedStudentIds;

  StudentModel? individualStudent;

  // Fetch Students by class id
  Future<void> fetchStudentsByClassId({required BuildContext context,required int classId,bool forSelection = false}) async {
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

  // student selection multiple
  void toggleStudentSelection(int studentId) {
    if (_selectedStudentIds.contains(studentId)) {
      _selectedStudentIds.remove(studentId);
    } else {
      _selectedStudentIds.add(studentId);
    }
    notifyListeners();
  }

  // student selection single
  void toggleSingleStudentSelection(int studentId) {
    if (_selectedStudentIds.contains(studentId)) {
      _selectedStudentIds.clear();
    } else {
      _selectedStudentIds
        ..clear()
        ..add(studentId);
    }
    notifyListeners();
  }

  // select all students
  void selectAllStudents() {
    _selectedStudentIds = _students.map((e) => e.id).toSet();
    notifyListeners();
  }

  void deselectAllStudents() {
    _selectedStudentIds.clear();
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
