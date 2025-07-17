import 'dart:developer';

import 'package:acadobs/features/teacher/data/services/student_services.dart';
import 'package:acadobs/shared/models/student_model.dart';
import 'package:flutter/material.dart';

class StudentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  StudentModel? individualStudent;

  // Fetch Students by class id
  Future<void> fetchStudentsByClassId({
    required int classId,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoading = true;

    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _students.clear();
        _isFetchedOnce = false;
      }
      final response = await StudentServices().fetchStudentsByClassId(
        classId: classId,
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List studentsJson = data['students'];

        final List<StudentModel> fetchedStudents =
            studentsJson
                .map((jsonItem) => StudentModel.fromJson(jsonItem))
                .toList();

        _students.addAll(fetchedStudents);
        _isFetchedOnce = true;
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
    _students.clear();
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
