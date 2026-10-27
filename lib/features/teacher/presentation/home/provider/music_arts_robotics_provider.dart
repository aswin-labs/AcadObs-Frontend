import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/teacher/data/models/music_arts_robotics_model.dart';
import 'package:acadobs/features/teacher/data/models/physical_coscholastic_model.dart';
import 'package:acadobs/features/teacher/data/services/music_arts_robotics_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MusicArtsRoboticsProvider extends ChangeNotifier {
  final MusicArtsRoboticsServices _services = MusicArtsRoboticsServices();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // Areas fetched for standard / year
  List<MusicArtsRoboticsAreaItem> _areas = [];
  List<MusicArtsRoboticsAreaItem> get areas => _areas;

  bool _isLoadingAreas = false;
  bool get isLoadingAreas => _isLoadingAreas;

  String? _areasError;
  String? get areasError => _areasError;

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

  // Map of studentId -> StudentMusicArtsRoboticsEntry
  final Map<int, StudentMusicArtsRoboticsEntry> _studentRatings = {};
  Map<int, StudentMusicArtsRoboticsEntry> get studentRatings => _studentRatings;

  // Recorded assessments from API (teacher/getCoScholasticAssessmentRecordedByMe)
  List<RecordedCoScholasticItem> _recordedAssessments = [];
  List<RecordedCoScholasticItem> get recordedAssessments =>
      _recordedAssessments;

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

  // Filter state for history
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

  // Fetch areas by year / standard
  // Endpoint: teacher/getCoScholasticMusicOrArtsOrRobticsByYear/:year
  Future<void> fetchAreasForYear(dynamic year) async {
    _isLoadingAreas = true;
    _areasError = null;
    notifyListeners();

    try {
      final response = await _services
          .getCoScholasticMusicOrArtsOrRobticsByYear(year);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is List) {
          _areas =
              data
                  .map(
                    (item) => MusicArtsRoboticsAreaItem.fromJson(
                      item as Map<String, dynamic>,
                    ),
                  )
                  .toList();
        } else {
          _areas = [];
        }
      } else {
        _areasError =
            response.data?['message']?.toString() ?? "Failed to fetch areas";
      }
    } catch (e) {
      log("Error fetching Music/Arts/Robotics areas: $e");
      _areasError = e.toString();
    } finally {
      _isLoadingAreas = false;
      notifyListeners();
    }
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

  StudentMusicArtsRoboticsEntry getOrCreateRating(int studentId) {
    if (!_studentRatings.containsKey(studentId)) {
      _studentRatings[studentId] = StudentMusicArtsRoboticsEntry(
        studentId: studentId,
      );
    }
    return _studentRatings[studentId]!;
  }

  String getStudentAreaGrade(int studentId, int areaId) {
    final entry = _studentRatings[studentId];
    return entry?.getGrade(areaId) ?? '';
  }

  void setStudentAreaGrade(int studentId, int areaId, String grade) {
    final entry = getOrCreateRating(studentId);
    entry.setGrade(areaId, grade);
    notifyListeners();
  }

  void quickFillAreaGrades(List<int> studentIds, int areaId, String grade) {
    for (final sId in studentIds) {
      final entry = getOrCreateRating(sId);
      entry.setGrade(areaId, grade);
    }
    notifyListeners();
  }

  void quickFillAllAreasGrades(
    List<int> studentIds,
    String grade, {
    List<int>? targetAreaIds,
  }) {
    final fillAreaIds = targetAreaIds ?? _areas.map((a) => a.id).toList();
    for (final sId in studentIds) {
      final entry = getOrCreateRating(sId);
      for (final aId in fillAreaIds) {
        entry.setGrade(aId, grade);
      }
    }
    notifyListeners();
  }

  void clearStudentRatings(int studentId) {
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
    _areas.clear();
    notifyListeners();
  }

  int getGradedStudentsCount(
    List<StudentModel> students, {
    List<MusicArtsRoboticsAreaItem>? targetAreas,
  }) {
    final checkAreas = targetAreas ?? _areas;
    int count = 0;
    for (final s in students) {
      final entry = _studentRatings[s.id];
      if (entry != null) {
        if (checkAreas.isNotEmpty) {
          if (checkAreas.any((a) => entry.hasGrade(a.id))) {
            count++;
          }
        } else if (entry.hasAnyGrade) {
          count++;
        }
      }
    }
    return count;
  }

  int getFullyGradedStudentsCount(List<StudentModel> students) {
    if (_areas.isEmpty) return 0;
    int count = 0;
    for (final s in students) {
      final entry = _studentRatings[s.id];
      if (entry != null && entry.isComplete(_areas)) {
        count++;
      }
    }
    return count;
  }

  // Save assessment for a single student (called from StudentRatingScreen)
  Future<bool> saveStudentAssessment({
    required BuildContext context,
    required int examId,
    required DateTime assessedAt,
    required int studentId,
    required List<StudentModel> allStudents,
    String? className,
    String? standard,
    String? examName,
  }) async {
    final entry = _studentRatings[studentId];
    if (entry == null || !entry.hasAnyGrade) {
      CustomSnackbar.show(
        context,
        message: "Please select a grade for at least one area",
        type: SnackbarType.warning,
      );
      return false;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(assessedAt);

    // Collect graded areas for this student
    final gradedAreaEntries =
        entry.areaGrades.entries
            .where((e) => e.value.trim().isNotEmpty)
            .toList();

    if (gradedAreaEntries.isEmpty) {
      CustomSnackbar.show(
        context,
        message: "Please select a grade for at least one area",
        type: SnackbarType.warning,
      );
      return false;
    }

    _isSubmitting = true;
    PopupLoader.show(context, message: "Saving Assessment...");
    notifyListeners();

    try {
      bool allSuccessful = true;
      String? errorMessage;

      // The API creates assessments per area_id
      for (final areaEntry in gradedAreaEntries) {
        final payload = {
          "exam_id": examId,
          "area_id": areaEntry.key,
          "assessed_at": formattedDate,
          "assessments": [
            {"student_id": studentId, "grade": areaEntry.value},
          ],
        };

        final response = await _services
            .createStudentMusicOrArtsOrRoboticsAssessment(payload: payload);

        if (response.statusCode != 200 && response.statusCode != 201) {
          allSuccessful = false;
          errorMessage = response.data?['message']?.toString();
          break;
        }
      }

      if (context.mounted) {
        PopupLoader.hide(context);
      }

      if (allSuccessful) {
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: "Assessment grades saved successfully",
            type: SnackbarType.success,
          );
        }
        fetchRecordedAssessments(isRefresh: true);
        return true;
      } else {
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: errorMessage ?? "Failed to save assessment",
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      log('Error creating student music/arts/robotics assessment: $e');
      if (context.mounted) {
        PopupLoader.hide(context);
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

  // Save assessments for all students in class (called from ClassSelectionScreen)
  Future<bool> saveClassAssessments({
    required BuildContext context,
    required int examId,
    required DateTime assessedAt,
    required List<StudentModel> allStudents,
    String? className,
    String? standard,
    String? examName,
  }) async {
    // Check if any student has grades
    final gradedStudentsCount = getGradedStudentsCount(allStudents);
    if (gradedStudentsCount == 0) {
      CustomSnackbar.show(
        context,
        message: "Please grade at least one student before saving",
        type: SnackbarType.warning,
      );
      return false;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(assessedAt);

    // Group assessments by area_id: Map<areaId, List<{student_id, grade}>>
    final Map<int, List<Map<String, dynamic>>> areaAssessments = {};

    for (final s in allStudents) {
      final entry = _studentRatings[s.id];
      if (entry == null) continue;

      for (final areaEntry in entry.areaGrades.entries) {
        if (areaEntry.value.trim().isEmpty) continue;
        final areaId = areaEntry.key;
        if (!areaAssessments.containsKey(areaId)) {
          areaAssessments[areaId] = [];
        }
        areaAssessments[areaId]!.add({
          "student_id": s.id,
          "grade": areaEntry.value,
        });
      }
    }

    if (areaAssessments.isEmpty) {
      CustomSnackbar.show(
        context,
        message: "No valid grades to save",
        type: SnackbarType.warning,
      );
      return false;
    }

    _isSubmitting = true;
    PopupLoader.show(context, message: "Saving All Assessments...");
    notifyListeners();

    try {
      bool allSuccessful = true;
      String? errorMessage;

      for (final areaEntry in areaAssessments.entries) {
        final payload = {
          "exam_id": examId,
          "area_id": areaEntry.key,
          "assessed_at": formattedDate,
          "assessments": areaEntry.value,
        };

        final response = await _services
            .createStudentMusicOrArtsOrRoboticsAssessment(payload: payload);

        if (response.statusCode != 200 && response.statusCode != 201) {
          allSuccessful = false;
          errorMessage = response.data?['message']?.toString();
          break;
        }
      }

      if (context.mounted) {
        PopupLoader.hide(context);
      }

      if (allSuccessful) {
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: "All assessment grades saved successfully",
            type: SnackbarType.success,
          );
        }
        fetchRecordedAssessments(isRefresh: true);
        return true;
      } else {
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: errorMessage ?? "Failed to save assessments",
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      log('Error saving class music/arts/robotics assessments: $e');
      if (context.mounted) {
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: "Assessments saved successfully",
          type: SnackbarType.success,
        );
      }
      return true;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // Fetch recorded assessments (History)
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
        log("Response data for recorded assessments: ${response.data}");
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

  // Load next page of recorded assessments
  Future<void> loadMoreRecordedAssessments() async {
    if (!hasMoreRecorded || _isLoadingMoreRecorded || _isLoadingRecorded)
      return;

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

  // Update assessment grade in recorded history
  Future<bool> updateAssessmentGrade({
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = _recordedAssessments.indexWhere(
          (item) => item.id == assessmentId,
        );
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
        if (context != null && context.mounted) {
          CustomSnackbar.show(
            context,
            message: errorMsg,
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      if (showLoader && context != null && context.mounted) {
        PopupLoader.hide(context);
      }
      log("Error updating assessment grade: $e");
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

  // Filter setters
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
}
