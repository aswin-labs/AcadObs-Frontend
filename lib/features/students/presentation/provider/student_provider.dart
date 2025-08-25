import 'dart:developer';

import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/data/services/student_services.dart';
import 'package:flutter/material.dart';

class StudentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  bool _hasFetched = false;
  bool get hasFetched => _hasFetched;

  Set<int> _selectedStudentIds = {};
  bool get isAllSelected =>
      _students.isNotEmpty && _selectedStudentIds.length == _students.length;
  Set<int> get selectedStudentIds => _selectedStudentIds;

  StudentModel? _individualStudent;
  StudentModel? get individualStudent => _individualStudent;

  // Fetch Students by class id
  Future<void> fetchStudentsByClassId({
    required BuildContext context,
    required int classId,
    bool forSelection = false,
  }) async {
    _isLoading = true;
    _hasFetched = false;
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
      _hasFetched = true;
      notifyListeners();
    }
  }

  // clear students
  void clearStudents() {
    _isLoading = false;
    _hasFetched = false;
    _students.clear();
    _individualStudent = null;
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

  // select all students
  void selectAllStudents() {
    _selectedStudentIds = _students.map((e) => e.id).toSet();
    notifyListeners();
  }

  void deselectAllStudents() {
    _selectedStudentIds.clear();
    notifyListeners();
  }

  // select single student
  void selectIndividualStudent(StudentModel student) {
    _individualStudent = student;
    notifyListeners();
  }

  // clear selection
  void clearIndividualStudent() {
    _individualStudent = null;
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
        _individualStudent = StudentModel.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //get student attendace by date
  int _totalPeriod = 0;
  int get totalPeriod => _totalPeriod;

  List<String> _status = [];
  List<String> get status => _status;

  Future<void> fetchAttendanceByDate({
    required int studentId,
    required String date,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await StudentServices().fetchAttendanceByDate(
        studentId: studentId,
        date: date,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _totalPeriod = data['period_count'] ?? 0;

        final List<dynamic> attendanceList = data['attendance'] ?? [];

        _status = List<String>.filled(_totalPeriod, "NA");

        for (final item in attendanceList) {
          final dynamic p = item['Attendance']?['period'];
          final int? period = (p is int) ? p : int.tryParse('$p');
          final String st = (item['status'] ?? 'NA').toString();

          if (period != null && period >= 1 && period <= _totalPeriod) {
            _status[period - 1] = st;
          }
        }

        log("total period: $_totalPeriod");
        log(" status list: $_status");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
