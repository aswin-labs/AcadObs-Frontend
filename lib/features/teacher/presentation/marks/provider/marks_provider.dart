import 'dart:developer';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/teacher/data/models/marks/marks_model.dart';
import 'package:acadobs/features/teacher/data/models/marks/student_mark_data.dart';
import 'package:acadobs/features/teacher/data/services/marks_services.dart';
import 'package:acadobs/shared/models/student_model.dart';
import 'package:flutter/material.dart';

class MarksProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  final List<MarksModel> _marks = [];
  List<MarksModel> get marks => _marks;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  // Map<int, dynamic> _addedStudentMarks = {};

  // Fetch marks
  Future<void> fetchAddedMarks({
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
        _marks.clear();
        _isFetchedOnce = false;
      }
      final response = await MarksServices().fetchMarksAddedByTeacher(
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List marksJson = data['exams'];

        final List<MarksModel> fetchHomeworks =
            marksJson.map((jsonItem) => MarksModel.fromJson(jsonItem)).toList();

        _marks.addAll(fetchHomeworks);
        _isFetchedOnce = true;
      } else {
        throw Exception('Failed to fetch marks: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<StudentMarkData> _marksList = [];
  List<StudentMarkData> get marksList => _marksList;

  // Initialize the list based on the students fetched from the API
  void initializeMarks(List<StudentModel> students) {
    if (_marksList.isNotEmpty) return; // Prevents re-initialization

    _marksList = students.map((student) => StudentMarkData(
      studentId: student.id, // Make sure your Student model has a unique 'id'
    )).toList();
  }

  // Update a student's mark
  void updateMark(int studentId, String mark) {
    final index = _marksList.indexWhere((s) => s.studentId == studentId);
    if (index != -1) {
      _marksList[index].marksObtained = mark;
      notifyListeners();
    }
  }

  // Toggle attendance status
  void toggleAttendance(int studentId) {
    final index = _marksList.indexWhere((s) => s.studentId == studentId);
    if (index != -1) {
      _marksList[index].attendanceStatus = 
          _marksList[index].attendanceStatus == "present" ? "absent" : "present";
      notifyListeners();
    }
  }

  // Get the final list ready for the API
  List<Map<String, dynamic>> getMarksForSubmission() {
    return _marksList.map((mark) => mark.toJson()).toList();
  }

  // Clean up when the screen is closed
  void clearMarks() {
    _marksList = [];
  }

  // Add student marks
  Future<void> addStudentMarks({
    required BuildContext context,
    required int classId,
    required String title,
    required String date,
    required int subjectId,
    required int totalMarks,
    // required List<Map<String, dynamic>> studentMarks,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await MarksServices().addStudentMarks(
        classId: classId,
        title: title,
        date: date,
        subjectId: subjectId,
        totalMarks: totalMarks,
        studentMarks: getMarksForSubmission(),
      );
      if (response.statusCode == 201) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Marks Added Successfully",
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }
}
