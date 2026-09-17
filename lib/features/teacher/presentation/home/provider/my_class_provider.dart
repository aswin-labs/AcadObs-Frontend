import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/marks/data/models/marks_model.dart';
import 'package:acadobs/features/teacher/data/models/competency_model.dart';
import 'package:acadobs/features/teacher/data/services/my_class_services.dart';
import 'package:flutter/material.dart';

class MyClassProvider extends ChangeNotifier {
  bool _isLoadingInternalMarks = false;
  bool _isLoadingMarks = false;

  bool get isLoadingInternalMarks => _isLoadingInternalMarks;
  bool get isLoadingMarks => _isLoadingMarks;

  final List<MarksModel> _marks = [];
  List<MarksModel> get marks => _marks;

  final List<MarksModel> _internalMarks = [];
  List<MarksModel> get internalMarks => _internalMarks;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  int _currentPageInternal = 1;
  int _totalPagesInternal = 1;

  bool get hasMoreInternal => _currentPageInternal < _totalPagesInternal;

  bool _isFetchedOnce = false;
  bool get isTermMarksFetchedOnce => _isFetchedOnce;

  bool _isFetchedOnceInternal = false;
  bool get isInternalMarksFetchedOnce => _isFetchedOnceInternal;

  // get my class term exam marks
  Future<void> fetchMyClassTermExamMarks({
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
      final response = await MyClassServices().fetchMyClassMarks(
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        log(data.toString());

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
      _isLoadingMarks = false;
      notifyListeners();
    }
  }

  // Get my class internal marks
  Future<void> fetchMyClassInternalMarks({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingInternalMarks) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnceInternal) return;

    _isLoadingInternalMarks = true;
    notifyListeners();
    try {
      if (loadMore) {
        _currentPageInternal++;
      } else {
        _currentPageInternal = 1;
        _internalMarks.clear();
        _isFetchedOnceInternal = false;
      }
      final response = await MyClassServices().fetchMyClassInternalMarks(
        pageNo: _currentPageInternal,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPagesInternal = data['totalPages'];
        _currentPageInternal = data['currentPage'];

        final List internalMarksJson = data['exams'];

        final List<MarksModel> fetchMarks =
            internalMarksJson
                .map((jsonItem) => MarksModel.fromJson(jsonItem))
                .toList();

        _internalMarks.addAll(fetchMarks);
        _isFetchedOnceInternal = true;
      } else {
        throw Exception(
          'Failed to fetch internalMarks: ${response.statusCode}',
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingInternalMarks = false;
      notifyListeners();
    }
  }

  // ==================== COMPETENCY ASSESSMENT ====================
  List<CompetencyModel> _competencies = [];
  List<CompetencyModel> get competencies => _competencies;

  bool _isLoadingCompetencies = false;
  bool get isLoadingCompetencies => _isLoadingCompetencies;

  bool _isLoadingStudentAssessment = false;
  bool get isLoadingStudentAssessment => _isLoadingStudentAssessment;

  bool _isSavingAssessment = false;
  bool get isSavingAssessment => _isSavingAssessment;

  bool _hasExistingAssessment = false;
  bool get hasExistingAssessment => _hasExistingAssessment;

  // Map of indicatorId -> StudentAssessmentEntry
  final Map<int, StudentAssessmentEntry> _studentRatings = {};
  Map<int, StudentAssessmentEntry> get studentRatings => _studentRatings;

  // Fetch Competencies & Indicators
  Future<void> fetchCompetencies({bool forceRefresh = false}) async {
    if (_competencies.isNotEmpty && !forceRefresh) return;
    if (_isLoadingCompetencies) return;

    _isLoadingCompetencies = true;
    notifyListeners();

    try {
      final response = await MyClassServices().fetchCompetencyAndIndicators();
      if (response.statusCode == 200) {
        final data = response.data;
        final List items = data['data'] is List ? data['data'] : [];
        _competencies = items
            .map((item) => CompetencyModel.fromJson(item as Map<String, dynamic>))
            .toList();
        _competencies.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
      }
    } catch (e) {
      log('Error fetching competencies: $e');
    } finally {
      _isLoadingCompetencies = false;
      notifyListeners();
    }
  }

  // Load Assessment for a specific Student and Exam
  Future<void> loadStudentAssessment({
    required int studentId,
    required int examId,
  }) async {
    _isLoadingStudentAssessment = true;
    _studentRatings.clear();
    _hasExistingAssessment = false;
    notifyListeners();

    try {
      final response = await MyClassServices().getCompetencyAssessmentByStudentIdAndExamId(
        studentId: studentId,
        examId: examId,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List rawList = [];
        if (data['data'] is List) {
          rawList = data['data'];
        } else if (data['assessments'] is List) {
          rawList = data['assessments'];
        } else if (data['data'] is Map && data['data']['assessments'] is List) {
          rawList = data['data']['assessments'];
        }

        for (final item in rawList) {
          if (item is Map<String, dynamic>) {
            final entry = StudentAssessmentEntry.fromJson(item);
            _studentRatings[entry.indicatorId] = entry;
          }
        }

        if (_studentRatings.isNotEmpty) {
          _hasExistingAssessment = true;
        }
      }
    } catch (e) {
      log('No existing assessment or error fetching: $e');
      _hasExistingAssessment = false;
    } finally {
      _isLoadingStudentAssessment = false;
      notifyListeners();
    }
  }

  // Update a single indicator rating locally
  void setIndicatorRating({
    required int competencyId,
    required int indicatorId,
    required int rating,
    String? remarks,
  }) {
    final existing = _studentRatings[indicatorId];
    _studentRatings[indicatorId] = StudentAssessmentEntry(
      competencyId: competencyId,
      indicatorId: indicatorId,
      rating: rating,
      remarks: remarks ?? existing?.remarks ?? '',
    );
    notifyListeners();
  }

  // Update a single indicator remarks locally
  void setIndicatorRemarks({
    required int competencyId,
    required int indicatorId,
    required String remarks,
  }) {
    final existing = _studentRatings[indicatorId];
    if (existing != null) {
      existing.remarks = remarks;
    } else {
      _studentRatings[indicatorId] = StudentAssessmentEntry(
        competencyId: competencyId,
        indicatorId: indicatorId,
        rating: 0,
        remarks: remarks,
      );
    }
    notifyListeners();
  }

  // Quick fill all indicators with a given rating
  void quickFillAllRatings(int rating) {
    for (final competency in _competencies) {
      for (final indicator in competency.indicators) {
        final existing = _studentRatings[indicator.id];
        _studentRatings[indicator.id] = StudentAssessmentEntry(
          competencyId: competency.id,
          indicatorId: indicator.id,
          rating: rating,
          remarks: existing?.remarks ?? '',
        );
      }
    }
    notifyListeners();
  }

  // Save or Update Assessment
  Future<bool> saveStudentAssessment({
    required BuildContext context,
    required int studentId,
    required int examId,
  }) async {
    final assessments = _studentRatings.values
        .where((entry) => entry.rating > 0)
        .map((entry) => entry.toJson())
        .toList();

    if (assessments.isEmpty) {
      CustomSnackbar.show(
        context,
        message: "Please rate at least one indicator before saving",
        type: SnackbarType.warning,
      );
      return false;
    }

    _isSavingAssessment = true;
    PopupLoader.show(context, message: _hasExistingAssessment ? "Updating Assessment..." : "Saving Assessment...");
    notifyListeners();

    try {
      dynamic response;
      if (_hasExistingAssessment) {
        try {
          response = await MyClassServices().bulkUpdateCompetencyAssessment(
            studentId: studentId,
            examId: examId,
            assessments: assessments,
          );
        } catch (_) {
          // If bulk update fails or endpoint prefers create, try create
          response = await MyClassServices().createStudentCompetencyAssessment(
            studentId: studentId,
            examId: examId,
            assessments: assessments,
          );
        }
      } else {
        response = await MyClassServices().createStudentCompetencyAssessment(
          studentId: studentId,
          examId: examId,
          assessments: assessments,
        );
      }

      if (context.mounted) {
        PopupLoader.hide(context);
      }

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        _hasExistingAssessment = true;
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: "Competency assessment saved successfully",
            type: SnackbarType.success,
          );
        }
        return true;
      } else {
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: response?.data?['message']?.toString() ?? "Failed to save assessment",
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      log('Error saving assessment: $e');
      if (context.mounted) {
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: "An error occurred while saving assessment",
          type: SnackbarType.failure,
        );
      }
      return false;
    } finally {
      _isSavingAssessment = false;
      notifyListeners();
    }
  }

  // Delete Assessment
  Future<bool> deleteStudentAssessment({
    required BuildContext context,
    required int studentId,
    required int examId,
  }) async {
    _isSavingAssessment = true;
    PopupLoader.show(context, message: "Deleting Assessment...");
    notifyListeners();

    try {
      final response = await MyClassServices().deleteCompetencyAssessment(
        studentId: studentId,
        examId: examId,
      );

      if (context.mounted) {
        PopupLoader.hide(context);
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        _studentRatings.clear();
        _hasExistingAssessment = false;
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: "Competency assessment deleted successfully",
            type: SnackbarType.success,
          );
        }
        return true;
      } else {
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: response.data?['message']?.toString() ?? "Failed to delete assessment",
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      log('Error deleting assessment: $e');
      if (context.mounted) {
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: "Failed to delete assessment",
          type: SnackbarType.failure,
        );
      }
      return false;
    } finally {
      _isSavingAssessment = false;
      notifyListeners();
    }
  }
}
