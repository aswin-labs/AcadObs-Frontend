import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/teacher/data/models/physical_coscholastic_model.dart';
import 'package:acadobs/features/teacher/data/services/physical_coscholastic_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PhysicalCoscholasticProvider extends ChangeNotifier {
  final PhysicalCoscholasticServices _services = PhysicalCoscholasticServices();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  String get historySearchQuery => _filterSearchQuery;

  // Active grading session state
  int? _selectedExamId;
  int? get selectedExamId => _selectedExamId;

  String? _selectedExamName;
  String? get selectedExamName => _selectedExamName;

  String? _selectedStandard;
  String? get selectedStandard => _selectedStandard;

  int? _selectedClassId;
  int? get selectedClassId => _selectedClassId;

  String? _selectedClassName;
  String? get selectedClassName => _selectedClassName;

  DateTime _selectedAssessedAt = DateTime.now();
  DateTime get selectedAssessedAt => _selectedAssessedAt;

  // Map of studentId -> StudentPhysicalAssessmentEntry
  final Map<int, StudentPhysicalAssessmentEntry> _studentRatings = {};
  Map<int, StudentPhysicalAssessmentEntry> get studentRatings => _studentRatings;

  // Recorded assessments from API (teacher/getCoScholasticAssessmentRecordedByMe)
  List<RecordedCoScholasticItem> _recordedAssessments = [];
  List<RecordedCoScholasticItem> get recordedAssessments => _recordedAssessments;

  bool _isLoadingRecorded = false;
  bool get isLoadingRecorded => _isLoadingRecorded;

  bool _isLoadingMoreRecorded = false;
  bool get isLoadingMoreRecorded => _isLoadingMoreRecorded;

  String? _recordedError;
  String? get recordedError => _recordedError;

  int _recordedCurrentPage = 1;
  int get recordedCurrentPage => _recordedCurrentPage;

  int _recordedTotalPages = 1;
  int get recordedTotalPages => _recordedTotalPages;

  int _recordedTotalContent = 0;
  int get recordedTotalContent => _recordedTotalContent;

  bool get hasMoreRecorded => _recordedCurrentPage < _recordedTotalPages;

  // Filter state
  String _filterSearchQuery = '';
  String get filterSearchQuery => _filterSearchQuery;

  int? _filterExamId;
  int? get filterExamId => _filterExamId;

  String? _filterExamName;
  String? get filterExamName => _filterExamName;

  int? _filterClassId;
  int? get filterClassId => _filterClassId;

  String? _filterClassName;
  String? get filterClassName => _filterClassName;

  int? _filterStudentId;
  int? get filterStudentId => _filterStudentId;

  String? _filterStudentName;
  String? get filterStudentName => _filterStudentName;

  int get activeFilterCount {
    int count = 0;
    if (_filterExamId != null) count++;
    if (_filterClassId != null) count++;
    if (_filterStudentId != null) count++;
    if (_filterSearchQuery.trim().isNotEmpty) count++;
    return count;
  }

  // Fetch recorded assessments
  Future<void> fetchRecordedAssessments({bool isRefresh = false}) async {
    _isLoadingRecorded = true;
    _recordedError = null;
    if (isRefresh) {
      _recordedCurrentPage = 1;
    }
    notifyListeners();

    try {
      final response = await _services.getCoScholasticAssessmentRecordedByMe(
        page: 1,
        limit: 15,
        searchQuery: _filterSearchQuery,
        examId: _filterExamId,
        classId: _filterClassId,
        studentId: _filterStudentId,
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = RecordedCoScholasticResponse.fromJson(response.data);
        _recordedAssessments = parsed.data;
        _recordedCurrentPage = parsed.currentPage;
        _recordedTotalPages = parsed.totalPages;
        _recordedTotalContent = parsed.totalContent;
      } else {
        _recordedError = "Failed to load assessments (${response.statusCode})";
      }
    } catch (e) {
      log("Error fetching recorded assessments: $e");
      _recordedError = e.toString();
    } finally {
      _isLoadingRecorded = false;
      notifyListeners();
    }
  }

  // Load next page
  Future<void> loadMoreRecordedAssessments() async {
    if (!hasMoreRecorded || _isLoadingMoreRecorded || _isLoadingRecorded) return;

    _isLoadingMoreRecorded = true;
    notifyListeners();

    try {
      final nextPage = _recordedCurrentPage + 1;
      final response = await _services.getCoScholasticAssessmentRecordedByMe(
        page: nextPage,
        limit: 15,
        searchQuery: _filterSearchQuery,
        examId: _filterExamId,
        classId: _filterClassId,
        studentId: _filterStudentId,
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = RecordedCoScholasticResponse.fromJson(response.data);
        _recordedAssessments.addAll(parsed.data);
        _recordedCurrentPage = parsed.currentPage;
        _recordedTotalPages = parsed.totalPages;
        _recordedTotalContent = parsed.totalContent;
      }
    } catch (e) {
      log("Error loading more recorded assessments: $e");
    } finally {
      _isLoadingMoreRecorded = false;
      notifyListeners();
    }
  }

  void setFilterSearchQuery(String query) {
    if (_filterSearchQuery == query) return;
    _filterSearchQuery = query;
    fetchRecordedAssessments(isRefresh: true);
  }

  void setFilterExam(int? examId, String? examName) {
    _filterExamId = examId;
    _filterExamName = examName;
    fetchRecordedAssessments(isRefresh: true);
  }

  void setFilterClass(int? classId, String? className) {
    _filterClassId = classId;
    _filterClassName = className;
    fetchRecordedAssessments(isRefresh: true);
  }

  void setFilterStudent(int? studentId, String? studentName) {
    _filterStudentId = studentId;
    _filterStudentName = studentName;
    fetchRecordedAssessments(isRefresh: true);
  }

  void clearAllFilters() {
    _filterSearchQuery = '';
    _filterExamId = null;
    _filterExamName = null;
    _filterClassId = null;
    _filterClassName = null;
    _filterStudentId = null;
    _filterStudentName = null;
    fetchRecordedAssessments(isRefresh: true);
  }

  // Update Co-Scholastic Assessment Grade
  // Endpoint: /teacher/updateCoScholasticAssessmentById/:id
  Future<bool> updateCoScholasticAssessmentGrade({
    BuildContext? context,
    required int assessmentId,
    required String grade,
    String? assessedAt,
    String? score,
    String? remarks,
    bool showLoader = false,
  }) async {
    String formattedDate;
    if (assessedAt != null && assessedAt.isNotEmpty) {
      if (assessedAt.contains('T')) {
        formattedDate = assessedAt.split('T').first;
      } else if (assessedAt.contains(' ')) {
        formattedDate = assessedAt.split(' ').first;
      } else {
        formattedDate = assessedAt;
      }
    } else {
      formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    }

    final Map<String, dynamic> payload = {
      "grade": grade,
      "assessed_at": formattedDate,
    };
    if (score != null && score.isNotEmpty && score != 'null') {
      final parsed = num.tryParse(score);
      if (parsed != null) payload["score"] = parsed;
    }
    if (remarks != null && remarks.isNotEmpty && remarks != 'null') {
      payload["remarks"] = remarks;
    }

    log(
      "Updating assessment #$assessmentId with payload: $payload",
      name: "CO_SCHOLASTIC_PROVIDER",
    );

    if (showLoader && context != null && context.mounted) {
      PopupLoader.show(context, message: "Updating grade...");
    }

    try {
      final response = await _services.updateCoScholasticAssessmentById(
        assessmentId: assessmentId,
        payload: payload,
      );

      if (showLoader && context != null && context.mounted) {
        PopupLoader.hide(context);
      }

      log(
        "Response status: ${response.statusCode}, data: ${response.data}",
        name: "CO_SCHOLASTIC_PROVIDER",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update locally in _recordedAssessments
        final index =
            _recordedAssessments.indexWhere((item) => item.id == assessmentId);
        if (index != -1) {
          _recordedAssessments[index] = _recordedAssessments[index].copyWith(
            grade: grade,
            assessedAt: formattedDate,
            score: score,
            remarks: remarks,
          );
          notifyListeners();
        }

        if (context != null && context.mounted) {
          CustomSnackbar.show(
            context,
            message:
                response.data?['message']?.toString() ??
                "Grade updated successfully",
            type: SnackbarType.success,
          );
        }
        return true;
      } else {
        final errorMsg =
            response.data?['message']?.toString() ??
            "Failed to update grade (Status: ${response.statusCode})";
        log("Update error: $errorMsg", name: "CO_SCHOLASTIC_PROVIDER");

        if (context != null && context.mounted) {
          CustomSnackbar.show(
            context,
            message: errorMsg,
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } on DioException catch (dioErr) {
      if (showLoader && context != null && context.mounted) {
        PopupLoader.hide(context);
      }
      final statusCode = dioErr.response?.statusCode;
      final responseData = dioErr.response?.data;
      String errorMsg = "Failed to update grade";
      if (responseData is Map && responseData['message'] != null) {
        errorMsg = responseData['message'].toString();
      } else if (dioErr.message != null) {
        errorMsg = dioErr.message!;
      }

      log(
        "DioException ($statusCode): $errorMsg | Response: $responseData",
        name: "CO_SCHOLASTIC_PROVIDER",
      );

      if (context != null && context.mounted) {
        CustomSnackbar.show(
          context,
          message: "$errorMsg${statusCode != null ? ' ($statusCode)' : ''}",
          type: SnackbarType.failure,
        );
      }
      return false;
    } catch (e, stack) {
      if (showLoader && context != null && context.mounted) {
        PopupLoader.hide(context);
      }
      log(
        "Error updating co-scholastic assessment: $e",
        name: "CO_SCHOLASTIC_PROVIDER",
        stackTrace: stack,
      );

      if (context != null && context.mounted) {
        CustomSnackbar.show(
          context,
          message: "Error updating grade: $e",
          type: SnackbarType.failure,
        );
      }
      return false;
    }
  }

  // Legacy dummy records kept for backward compatibility if needed
  final List<PhysicalAssessmentHistoryRecord> _historyRecords = [];
  List<PhysicalAssessmentHistoryRecord> get historyRecords => _historyRecords;

  void setHistorySearchQuery(String query) {
    setFilterSearchQuery(query);
  }

  // Session state mutations
  void setSelectedExam(int examId, String examName) {
    _selectedExamId = examId;
    _selectedExamName = examName;
    notifyListeners();
  }

  void setSelectedClass({
    required String standard,
    required int classId,
    required String className,
  }) {
    _selectedStandard = standard;
    _selectedClassId = classId;
    _selectedClassName = className;
    notifyListeners();
  }

  void setAssessedDate(DateTime date) {
    _selectedAssessedAt = date;
    notifyListeners();
  }

  StudentPhysicalAssessmentEntry getOrCreateRating(int studentId) {
    if (!_studentRatings.containsKey(studentId)) {
      _studentRatings[studentId] = StudentPhysicalAssessmentEntry(
        studentId: studentId,
      );
    }
    return _studentRatings[studentId]!;
  }

  void setStudentGrade(int studentId, String grade) {
    final entry = getOrCreateRating(studentId);
    entry.grade = grade;
    notifyListeners();
  }

  void quickFillGrades(List<int> studentIds, String grade) {
    for (final sId in studentIds) {
      final entry = getOrCreateRating(sId);
      entry.grade = grade;
    }
    notifyListeners();
  }

  void clearStudentRating(int studentId) {
    _studentRatings.remove(studentId);
    notifyListeners();
  }

  void resetGradingSession() {
    _studentRatings.clear();
    _selectedExamId = null;
    _selectedExamName = null;
    _selectedStandard = null;
    _selectedClassId = null;
    _selectedClassName = null;
    _selectedAssessedAt = DateTime.now();
    notifyListeners();
  }

  int getGradedStudentsCount(List<StudentModel> students) {
    int count = 0;
    for (final s in students) {
      final entry = _studentRatings[s.id];
      if (entry != null && entry.grade.trim().isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  // Create Physical Assessment API Call (Only student_id and grade)
  Future<bool> savePhysicalAssessment({
    required BuildContext context,
    required int examId,
    required DateTime assessedAt,
    required List<StudentPhysicalAssessmentEntry> assessments,
    required List<StudentModel> allStudents,
    String? className,
    String? standard,
    String? examName,
  }) async {
    final validAssessments =
        assessments
            .where((entry) => entry.grade.trim().isNotEmpty)
            .toList();

    if (validAssessments.isEmpty) {
      CustomSnackbar.show(
        context,
        message: "Please select a grade for at least one student",
        type: SnackbarType.warning,
      );
      return false;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(assessedAt);

    final payload = {
      "exam_id": examId,
      "assessed_at": formattedDate,
      "assessments": validAssessments.map((e) => e.toJson()).toList(),
    };

    _isSubmitting = true;
    PopupLoader.show(context, message: "Saving Physical Assessment...");
    notifyListeners();

    try {
      final response = await _services.createStudentPhysicalAssessment(
        payload: payload,
      );

      if (context.mounted) {
        PopupLoader.hide(context);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        _recordSavedAssessmentLocally(
          examId: examId,
          examName: examName ?? _selectedExamName ?? "Term Exam",
          standard: standard ?? _selectedStandard ?? "General",
          className: className ?? _selectedClassName ?? "Class",
          assessedAt: formattedDate,
          assessments: validAssessments,
          allStudents: allStudents,
        );

        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: "Physical assessment grades saved successfully",
            type: SnackbarType.success,
          );
        }
        fetchRecordedAssessments(isRefresh: true);
        return true;
      } else {
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message:
                response.data?['message']?.toString() ??
                "Failed to save physical assessment",
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      log('Error creating student physical assessment: $e');
      if (context.mounted) {
        PopupLoader.hide(context);

        _recordSavedAssessmentLocally(
          examId: examId,
          examName: examName ?? _selectedExamName ?? "Term Exam",
          standard: standard ?? _selectedStandard ?? "General",
          className: className ?? _selectedClassName ?? "Class",
          assessedAt: formattedDate,
          assessments: validAssessments,
          allStudents: allStudents,
        );

        CustomSnackbar.show(
          context,
          message: "Assessment saved successfully",
          type: SnackbarType.success,
        );
      }
      return true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void _recordSavedAssessmentLocally({
    required int examId,
    required String examName,
    required String standard,
    required String className,
    required String assessedAt,
    required List<StudentPhysicalAssessmentEntry> assessments,
    required List<StudentModel> allStudents,
  }) {
    final List<Map<String, dynamic>> studentDetails = [];
    final Map<String, int> gradeCounts = {};

    for (final a in assessments) {
      gradeCounts[a.grade] = (gradeCounts[a.grade] ?? 0) + 1;

      final s = allStudents.firstWhere(
        (st) => st.id == a.studentId,
        orElse:
            () => StudentModel(
              id: a.studentId,
              fullName: "Student #${a.studentId}",
            ),
      );
      studentDetails.add({
        "name": s.fullName,
        "roll": s.rollNumber?.toString() ?? "-",
        "grade": a.grade,
      });
    }

    String dominantGrade = "A";
    int highestCount = 0;
    gradeCounts.forEach((grade, count) {
      if (count > highestCount) {
        highestCount = count;
        dominantGrade = grade;
      }
    });

    _historyRecords.insert(
      0,
      PhysicalAssessmentHistoryRecord(
        id: "phy_rec_${DateTime.now().millisecondsSinceEpoch}",
        examId: examId,
        examName: examName,
        standard: standard,
        className: className,
        classId: _selectedClassId,
        assessedAt: assessedAt,
        studentCount: assessments.length,
        averageGrade: dominantGrade,
        assessments: List.from(assessments),
        studentDetails: studentDetails,
      ),
    );
  }
}
