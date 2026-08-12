import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/marks/data/models/marks_model.dart';
import 'package:acadobs/features/marks/data/models/student_mark_model.dart';
import 'package:acadobs/features/marks/data/services/marks_services.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MarksProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingForSingleMarks = false;
  bool get isLoadingForSingleMarks => _isLoadingForSingleMarks;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  bool _isLoadingForEditDetails = false;
  bool get isLoadingForEditDetails => _isLoadingForEditDetails;

  bool _isCheckingInternal = false;
  bool get isCheckingInternal => _isCheckingInternal;

  final List<MarksModel> _marks = [];
  List<MarksModel> get marks => _marks;

  MarksModel? singleMarks;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;
  bool isFetchedOnceForStudent = false;

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

        final List<MarksModel> fetchMarks =
            marksJson.map((jsonItem) => MarksModel.fromJson(jsonItem)).toList();

        _marks.addAll(fetchMarks);
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

  // Get Single mark
  Future<void> fetchSingleMarks({required int marksId}) async {
    _isLoadingForSingleMarks = true;
    try {
      final response = await MarksServices().fetchSingleMarks(marksId: marksId);
      if (response.statusCode == 200) {
        final data = response.data;
        log(data.toString());
        singleMarks = MarksModel.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingForSingleMarks = false;
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
        await fetchAddedMarks(forceRefresh: true);
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
    String? title,
    String? date,
    int? subjectId,
    double? totalMarks,
  }) async {
    _isLoadingForEditDetails = true;
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
        if (!context.mounted) return;
        await context.read<TermExamProvider>().fetchAddedTermExamMarks(
          forceRefresh: true,
        );
        await fetchSingleMarks(marksId: marksId);
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
      _isLoadingForEditDetails = false;
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
        await fetchSingleMarks(marksId: marksId);
        if (!context.mounted) return;
        PopupLoader.hide(context);
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
    required bool forStaff,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      if (loadMore) {
        if (_currentPageForStudent >= _totalPagesForStudent) {
          _isLoading = false;
          return;
        }
        _currentPageForStudent++;
      } else {
        _currentPageForStudent = 1;
        _studentMarks.clear();
        isFetchedOnceForStudent = false;
      }
      final response = await MarksServices().fetchStudentMarks(
        studentId: studentId,
        forStaff: forStaff,
        pageNo: _currentPageForStudent,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPagesForStudent = data['totalPages'];
        _currentPageForStudent = data['currentPage'];

        final List marksJson = data['Mark'];

        final List<StudentMarkModel> fetchMarks =
            marksJson
                .map((jsonItem) => StudentMarkModel.fromJson(jsonItem))
                .toList();

        _studentMarks.addAll(fetchMarks);
        log(_studentMarks.toString());
        isFetchedOnceForStudent = true;
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

  //  // fetch existing internal marks
  Future<bool> checkExistingTermMarks({
    required int classId,
    required String title,
    required String date,
    required int subjectId,
  }) async {
    _isCheckingInternal = true;
    notifyListeners();

    try {
      final response = await MarksServices().checkExistingInternalMarks(
        classId: classId,
        title: title,
        date: date,
        subjectId: subjectId,
      );

      if (response.statusCode == 200) {
        return response.data['success'] == true;
      }

      return false;
    } catch (e) {
      log(e.toString());
      return false;
    } finally {
      _isCheckingInternal = false;
      notifyListeners();
    }
  }

  bool _isLoadingMissingStudents = false;
  bool get isLoadingMissingStudents => _isLoadingMissingStudents;

  bool _isAddingMissingStudentMarks = false;
  bool get isAddingMissingStudentMarks => _isAddingMissingStudentMarks;

  List<StudentModel> _missingStudents = [];
  List<StudentModel> get missingStudents => _missingStudents;

  Future<void> fetchMissingStudents({
    required int classId,
    required List<int> studentIds,
  }) async {
    _isLoadingMissingStudents = true;
    _missingStudents.clear();
    notifyListeners();

    try {
      final response = await MarksServices().fetchMissingStudents(
        classId: classId,
        studentIds: studentIds,
      );

      if (response.statusCode == 200) {
        final List studentsJson = response.data['missingStudents'] ?? [];

        _missingStudents =
            studentsJson
                .map((student) => StudentModel.fromJson(student))
                .toList();
      }
    } catch (e) {
      log('Fetch missing students error: $e');
    } finally {
      _isLoadingMissingStudents = false;
      notifyListeners();
    }
  }

  Future<bool> createNewMarksByInternalId({
    required BuildContext context,
    required int internalId,
    required List<Map<String, dynamic>> studentMarks,
  }) async {
    _isAddingMissingStudentMarks = true;
    notifyListeners();

    try {
      final response = await MarksServices().createNewMarksByInternalId(
        internalId: internalId,
        studentMarks: studentMarks,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSingleMarks(marksId: internalId);
        if (!context.mounted) return false;
        CustomSnackbar.show(
          context,
          message: response.data['message'] ?? 'Marks added successfully',
          type: SnackbarType.success,
        );

        return true;
      }

      return false;
    } on DioException catch (e) {
      log('Status Code: ${e.response?.statusCode}');
      log('Response Data: ${e.response?.data}');
      log('Request Data: ${e.requestOptions.data}');

      if (!context.mounted) return false;

      CustomSnackbar.show(
        context,
        message:
            e.response?.data?['message'] ??
            e.response?.data?['error'] ??
            'Failed to add marks',
        type: SnackbarType.failure,
      );

      return false;
    } catch (e) {
      log('Add missing student marks error: $e');

      if (!context.mounted) return false;

      CustomSnackbar.show(
        context,
        message: 'Something went wrong while adding marks',
        type: SnackbarType.failure,
      );

      return false;
    } finally {
      _isAddingMissingStudentMarks = false;
      notifyListeners();
    }
  }

  // Delete mark by markId
  Future<void> deleteMarkById({
    required BuildContext context,
    required int markId,
    required int internalId,
  }) async {
    PopupLoader.show(context, message: "Deleting...");
    try {
      final response = await MarksServices().deleteMarkById(markId: markId);
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSingleMarks(marksId: internalId);
        if (!context.mounted) return;
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: response.data['message'] ?? "Mark deleted successfully",
          type: SnackbarType.success,
        );
      } else {
        if (!context.mounted) return;
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: "Failed to delete mark",
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log('Delete mark error: $e');
      if (!context.mounted) return;
      PopupLoader.hide(context);
      CustomSnackbar.show(
        context,
        message: "Something went wrong while deleting mark",
        type: SnackbarType.failure,
      );
    }
  }
}
