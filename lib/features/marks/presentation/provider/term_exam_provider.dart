import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/marks/data/models/marks_model.dart';
import 'package:acadobs/features/marks/data/models/student_mark_model.dart';
import 'package:acadobs/features/marks/data/services/term_exam_services.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TermExamProvider extends ChangeNotifier {
  bool _isLoadingExams = false;
  bool _isLoadingMarks = false;
  bool _isLoadingStudentMarks = false;
  bool _isLoadingMultiSubjectMarks = false;
  bool _isCheckingInternal = false;
  bool _isLoadingForSingleMarks = false;

  bool get isLoadingExams => _isLoadingExams;
  bool get isLoadingMarks => _isLoadingMarks;
  bool get isLoadingStudentMarks => _isLoadingStudentMarks;
  bool get isLoadingMultiSubjectMarks => _isLoadingMultiSubjectMarks;
  bool get isCheckingInternal => _isCheckingInternal;
  bool get isLoadingForSingleMarks => _isLoadingForSingleMarks;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  final List<MarksModel> _marks = [];
  List<MarksModel> get marks => _marks;

  final List<MarksModel> _multiSubjectMarks = [];
  List<MarksModel> get multiSubjectMarks => _multiSubjectMarks;

  final List<StudentMarkModel> _studentMarks = [];
  List<StudentMarkModel> get studentMarks => _studentMarks;

  MarksModel? singleMarks;

  int _currentPage = 1;
  int _totalPages = 1;

  int _currentPageForStudent = 1;
  int _totalPagesForStudent = 1;

  int _currentPageForMultiSubjectMarks = 1;
  int _totalPagesForMultiSubjectMarks = 1;

  bool get hasMore => _currentPage < _totalPages;
  bool get hasMoreStudentMarks =>
      _currentPageForStudent < _totalPagesForStudent;
  bool get hasMoreMultiSubjectMarks =>
      _currentPageForMultiSubjectMarks < _totalPagesForMultiSubjectMarks;

  bool _isFetchedOnce = false;
  bool isFetchedOnceForStudent = false;
  bool _isFetchedOnceForMultiSubjectMarks = false;
  List<Map<String, dynamic>> _termExams = [];

  List<Map<String, dynamic>> get termExams => List.unmodifiable(_termExams);

  // fetch term exams
  Future<void> fetchTermExams() async {
    _isLoadingExams = true;
    notifyListeners();
    try {
      final response = await TermExamServices().fetchTermExams();
      if (response.statusCode == 200) {
        final data = response.data;
        final List examsJson = data['data'];
        _termExams =
            examsJson
                .map((jsonItem) => Map<String, dynamic>.from(jsonItem))
                .toList();
      } else {
        throw Exception('Failed to fetch term exams: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingExams = false;
      notifyListeners();
    }
  }

  // Filter state for Added Term Exam Marks
  int? _filterSubjectId;
  String? _filterSubjectName;
  int? _filterClassId;
  String? _filterClassName;
  String? _filterStandard;
  int? _filterExamId;
  String? _filterExamName;
  String _searchQuery = '';

  int? get filterSubjectId => _filterSubjectId;
  String? get filterSubjectName => _filterSubjectName;
  int? get filterClassId => _filterClassId;
  String? get filterClassName => _filterClassName;
  String? get filterStandard => _filterStandard;
  int? get filterExamId => _filterExamId;
  String? get filterExamName => _filterExamName;
  String get searchQuery => _searchQuery;

  bool get hasActiveFilters =>
      _filterSubjectId != null ||
      _filterClassId != null ||
      _filterExamId != null ||
      _searchQuery.isNotEmpty;

  int get activeFilterCount {
    int count = 0;
    if (_filterExamId != null) count++;
    if (_filterClassId != null) count++;
    if (_filterSubjectId != null) count++;
    return count;
  }

  // Filter state for Multi Teacher Subject Marks
  int? _multiFilterSubjectId;
  String? _multiFilterSubjectName;
  int? _multiFilterClassId;
  String? _multiFilterClassName;
  String? _multiFilterStandard;
  int? _multiFilterExamId;
  String? _multiFilterExamName;
  String _multiSearchQuery = '';

  int? get multiFilterSubjectId => _multiFilterSubjectId;
  String? get multiFilterSubjectName => _multiFilterSubjectName;
  int? get multiFilterClassId => _multiFilterClassId;
  String? get multiFilterClassName => _multiFilterClassName;
  String? get multiFilterStandard => _multiFilterStandard;
  int? get multiFilterExamId => _multiFilterExamId;
  String? get multiFilterExamName => _multiFilterExamName;
  String get multiSearchQuery => _multiSearchQuery;

  bool get hasActiveMultiFilters =>
      _multiFilterSubjectId != null ||
      _multiFilterClassId != null ||
      _multiFilterExamId != null ||
      _multiSearchQuery.isNotEmpty;

  int get multiActiveFilterCount {
    int count = 0;
    if (_multiFilterExamId != null) count++;
    if (_multiFilterClassId != null) count++;
    if (_multiFilterSubjectId != null) count++;
    return count;
  }

  // Fetch marks
  Future<void> fetchAddedTermExamMarks({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingMarks) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoadingMarks = true;
    notifyListeners();
    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _marks.clear();
        _isFetchedOnce = false;
      }
      final response = await TermExamServices()
          .fetchTermExamMarksAddedByTeacher(
            pageNo: _currentPage,
            subjectId: _filterSubjectId,
            classId: _filterClassId,
            examId: _filterExamId,
            query: _searchQuery,
          );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'] ?? 1;
        _currentPage = data['currentPage'] ?? 1;

        final List marksJson = data['exams'] ?? [];

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
      _isLoadingMarks = false;
      notifyListeners();
    }
  }

  // Apply filters
  Future<void> applyTermExamFilters({
    int? subjectId,
    String? subjectName,
    int? classId,
    String? className,
    String? standard,
    int? examId,
    String? examName,
  }) async {
    _filterSubjectId = subjectId;
    _filterSubjectName = subjectName;
    _filterClassId = classId;
    _filterClassName = className;
    _filterStandard = standard;
    _filterExamId = examId;
    _filterExamName = examName;
    await fetchAddedTermExamMarks(forceRefresh: true);
  }

  // Clear all filters
  Future<void> clearTermExamFilters() async {
    _filterSubjectId = null;
    _filterSubjectName = null;
    _filterClassId = null;
    _filterClassName = null;
    _filterStandard = null;
    _filterExamId = null;
    _filterExamName = null;
    _searchQuery = '';
    await fetchAddedTermExamMarks(forceRefresh: true);
  }

  // Search query helper
  Future<void> searchTermExamMarks(String query) async {
    _searchQuery = query.trim();
    await fetchAddedTermExamMarks(forceRefresh: true);
  }

  Future<void> clearSearchQuery() async {
    _searchQuery = '';
    await fetchAddedTermExamMarks(forceRefresh: true);
  }

  // Clear single filter helpers
  Future<void> clearSubjectFilter() async {
    _filterSubjectId = null;
    _filterSubjectName = null;
    await fetchAddedTermExamMarks(forceRefresh: true);
  }

  Future<void> clearClassFilter() async {
    _filterClassId = null;
    _filterClassName = null;
    _filterStandard = null;
    await fetchAddedTermExamMarks(forceRefresh: true);
  }

  Future<void> clearExamFilter() async {
    _filterExamId = null;
    _filterExamName = null;
    await fetchAddedTermExamMarks(forceRefresh: true);
  }

  // Add student marks
  Future<void> addStudentTermExamMarks({
    required BuildContext context,
    required int classId,
    required String title,
    required String date,
    required int subjectId,
    required int totalMarks,
    required int termExamId,
    required List<Map<String, dynamic>> studentMarks,
  }) async {
    _isLoadingTwo = true;
    PopupLoader.show(context, message: "Adding Marks...");
    notifyListeners();
    try {
      final response = await TermExamServices().addStudentTermExamMarks(
        classId: classId,
        title: title,
        date: date,
        subjectId: subjectId,
        totalMarks: totalMarks,
        studentMarks: studentMarks,
        termExamId: termExamId,
      );
      if (response.statusCode == 201) {
        await fetchAddedTermExamMarks(forceRefresh: true);
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

  void clearStudentMarks() {
    _studentMarks.clear();
    _currentPageForStudent = 1;
    _totalPagesForStudent = 1;
    isFetchedOnceForStudent = false;
    _isLoadingStudentMarks = false;
    notifyListeners();
  }

  // fetch student term exam marks
  Future<void> fetchStudentTermExamMarks({
    required int studentId,
    required bool forStaff,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingStudentMarks) return;
    if (loadMore && !hasMoreStudentMarks) return;

    _isLoadingStudentMarks = true;
    if (!loadMore) {
      _studentMarks.clear();
      isFetchedOnceForStudent = false;
      _currentPageForStudent = 1;
      _totalPagesForStudent = 1;
    }
    notifyListeners();

    try {
      final int targetPage = loadMore ? _currentPageForStudent + 1 : 1;
      final response = await TermExamServices().fetchStudentTermExamMarks(
        studentId: studentId,
        forStaff: forStaff,
        pageNo: targetPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPagesForStudent = data['totalPages'] ?? 1;
        _currentPageForStudent = data['currentPage'] ?? targetPage;

        final List marksJson = data['Mark'] ?? [];

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
      _isLoadingStudentMarks = false;
      notifyListeners();
    }
  }

  // delete marks
  Future<void> deleteTermExamMarks({
    required BuildContext context,
    required int marksId,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await TermExamServices().deleteTermExamMarks(
        marksId: marksId,
      );
      if (response.statusCode == 200) {
        await fetchAddedTermExamMarks(forceRefresh: true);
        if (!context.mounted) return;
        await context.read<MarksProvider>().fetchAddedMarks(forceRefresh: true);
        if (!context.mounted) return;
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Marks Deleted Successfully",
          type: SnackbarType.success,
        );
      } else {
        log('Failed to delete Marks ${response.statusCode}');
      }
      notifyListeners();
    } catch (e) {
      log('Error deleting Marks: $e');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Fetch multi teacher subject marks
  Future<void> fetchMultiTeacherSubjectMarks({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingMultiSubjectMarks) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnceForMultiSubjectMarks) {
      return;
    }
    _isLoadingMultiSubjectMarks = true;
    notifyListeners();
    try {
      if (loadMore) {
        _currentPageForMultiSubjectMarks++;
      } else {
        _currentPageForMultiSubjectMarks = 1;
        _multiSubjectMarks.clear();
        _isFetchedOnceForMultiSubjectMarks = false;
      }
      final response = await TermExamServices().fetchMultiTeacherSubjectMarks(
        pageNo: _currentPageForMultiSubjectMarks,
        examId: _multiFilterExamId,
        classId: _multiFilterClassId,
        subjectId: _multiFilterSubjectId,
        searchQuery: _multiSearchQuery,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPagesForMultiSubjectMarks = data['totalPages'];
        _currentPageForMultiSubjectMarks = data['currentPage'];

        final List marksJson = data['internalMarks'];

        final List<MarksModel> fetchMarks =
            marksJson.map((jsonItem) => MarksModel.fromJson(jsonItem)).toList();

        _multiSubjectMarks.addAll(fetchMarks);
        _isFetchedOnceForMultiSubjectMarks = true;
      } else {
        throw Exception('Failed to fetch marks: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingMultiSubjectMarks = false;
      notifyListeners();
    }
  }

  // Multi Teacher Filter Helpers
  Future<void> applyMultiTeacherFilters({
    int? examId,
    String? examName,
    String? standard,
    int? classId,
    String? className,
    int? subjectId,
    String? subjectName,
  }) async {
    _multiFilterExamId = examId;
    _multiFilterExamName = examName;
    _multiFilterStandard = standard;
    _multiFilterClassId = classId;
    _multiFilterClassName = className;
    _multiFilterSubjectId = subjectId;
    _multiFilterSubjectName = subjectName;
    await fetchMultiTeacherSubjectMarks(forceRefresh: true);
  }

  Future<void> clearMultiTeacherFilters() async {
    _multiFilterSubjectId = null;
    _multiFilterSubjectName = null;
    _multiFilterClassId = null;
    _multiFilterClassName = null;
    _multiFilterStandard = null;
    _multiFilterExamId = null;
    _multiFilterExamName = null;
    _multiSearchQuery = '';
    await fetchMultiTeacherSubjectMarks(forceRefresh: true);
  }

  Future<void> searchMultiTeacherMarks(String query) async {
    _multiSearchQuery = query.trim();
    await fetchMultiTeacherSubjectMarks(forceRefresh: true);
  }

  Future<void> clearMultiSearchQuery() async {
    _multiSearchQuery = '';
    await fetchMultiTeacherSubjectMarks(forceRefresh: true);
  }

  Future<void> clearMultiSubjectFilter() async {
    _multiFilterSubjectId = null;
    _multiFilterSubjectName = null;
    await fetchMultiTeacherSubjectMarks(forceRefresh: true);
  }

  Future<void> clearMultiClassFilter() async {
    _multiFilterClassId = null;
    _multiFilterClassName = null;
    _multiFilterStandard = null;
    await fetchMultiTeacherSubjectMarks(forceRefresh: true);
  }

  Future<void> clearMultiExamFilter() async {
    _multiFilterExamId = null;
    _multiFilterExamName = null;
    await fetchMultiTeacherSubjectMarks(forceRefresh: true);
  }

  // fetch existing term marks
  Future<bool> checkExistingTermMarks({
    required int classId,
    required String title,
    required String date,
    required int subjectId,
    required int termExamId,
  }) async {
    _isCheckingInternal = true;
    notifyListeners();

    try {
      final response = await TermExamServices().checkExistingTermMarks(
        classId: classId,
        title: title,
        date: date,
        subjectId: subjectId,
        termExamId: termExamId,
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

  // Get Single multi teacher subject mark
  Future<void> fetchSingleMultiTeacherSubjectMarks({
    required int marksId,
    required int subjectId,
  }) async {
    _isLoadingForSingleMarks = true;
    singleMarks = null;
    notifyListeners();

    try {
      final response = await TermExamServices()
          .fetchSingleMultiTeacherSubjectMarks(
            marksId: marksId,
            subjectId: subjectId,
          );

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
}
