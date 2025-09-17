import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/marks/data/models/marks_model.dart';
import 'package:acadobs/features/marks/data/models/student_mark_model.dart';
import 'package:acadobs/features/marks/data/services/marks_services.dart';
import 'package:flutter/material.dart';

class MarksProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  final List<MarksModel> _marks = [];
  List<MarksModel> get marks => _marks;

  MarksModel? singleMarks;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  final List<StudentMarkModel> _studentMarks = [];
  List<StudentMarkModel> get studentMarks => _studentMarks;

  int _currentPageForStudent = 1;
  int _totalPagesForStudent = 1;

  bool get hasMoreForStudent => _currentPageForStudent < _totalPagesForStudent;

  // bool _isFetchedOnceForStudent = false;

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

  // Get Single homework
  Future<void> fetchSingleMarks({required int marksId}) async {
    _isLoading = true;
    try {
      final response = await MarksServices().fetchSingleMarks(marksId: marksId);
      if (response.statusCode == 200) {
        final data = response.data;
        singleMarks = MarksModel.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add student marks
  Future<void> addStudentMarks({
    required BuildContext context,
    required int classId,
    required String title,
    required String date,
    required int subjectId,
    required int totalMarks,
    required List<Map<String, dynamic>> studentMarks,
  }) async {
    _isLoadingTwo = true;
    PopupLoader.show(context, message: "Adding Marks...");
    notifyListeners();
    try {
      final response = await MarksServices().addStudentMarks(
        classId: classId,
        title: title,
        date: date,
        subjectId: subjectId,
        totalMarks: totalMarks,
        studentMarks: studentMarks,
      );
      if (response.statusCode == 201) {
        if (!context.mounted) return;
        PopupLoader.hide(context);
        Navigator.pop(context);
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

  // Edit marks details
  Future<void> editMarksDetails({
    required BuildContext context,
    required int marksId,
    required String title,
    required String date,
    required int subjectId,
    required double totalMarks,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await MarksServices().editMarksDetails(
        marksId: marksId,
        title: title,
        totalMarks: totalMarks,
        date: date,
        subjectId: subjectId,
      );
      if (response.statusCode == 200) {
        await fetchAddedMarks(forceRefresh: true);
        if (!context.mounted) return;
        Navigator.pop(context);
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Mark Details Saved",
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

  // edit student marks
  Future<void> editStudentMarks({
    required BuildContext context,
    required int marksId,
    required List<Map<String, dynamic>> editedMarks,
  }) async {
    _isLoadingTwo = true;
    PopupLoader.show(context, message: "Adding Marks...");
    notifyListeners();
    try {
      final response = await MarksServices().editStudentMarks(
        marksId: marksId,
        editedMarks: editedMarks,
      );
      if (response.statusCode == 200) {
        if (!context.mounted) return;
        PopupLoader.hide(context);
        Navigator.pop(context);
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Marks Edited Successfully",
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

  // fetch student Marks
  Future<void> fetchStudentMarks({
    required int studentId,
    required bool forParent,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    // If not loading more, check if already fetched once.
    // if (!loadMore && !forceRefresh) return;

    _isLoading = true;

    try {
      if (loadMore) {
        _currentPageForStudent++;
      } else {
        _currentPageForStudent = 1;
        _studentMarks.clear();
        // _isFetchedOnceForStudent = false;
      }
      final response = await MarksServices().fetchStudentMarks(
        studentId: studentId,
        forParent: forParent,
        pageNo: _currentPageForStudent,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPagesForStudent = data['totalPages'];
        _currentPageForStudent = data['currentPage'];

        final List marksJson = data['Mark'];

        final List<StudentMarkModel> fetchHomeworks =
            marksJson
                .map((jsonItem) => StudentMarkModel.fromJson(jsonItem))
                .toList();

        _studentMarks.addAll(fetchHomeworks);
        log(_studentMarks.toString());
        // _isFetchedOnceForStudent = true;
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
}
