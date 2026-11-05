import 'dart:developer';

import 'package:acadobs/features/exam_timetable/data/models/exam_timetable_model.dart';
import 'package:acadobs/features/exam_timetable/data/services/exam_timetable_services.dart';
import 'package:flutter/material.dart';

class ExamTimetableProvider extends ChangeNotifier {
  final ExamTimetableServices _services = ExamTimetableServices();

  bool _isLoadingTitles = false;
  bool get isLoadingTitles => _isLoadingTitles;

  List<String> _examTitles = [];
  List<String> get examTitles => _examTitles;

  // Guardian Exams (Terms) State
  bool _isLoadingGuardianExams = false;
  bool get isLoadingGuardianExams => _isLoadingGuardianExams;

  List<Map<String, dynamic>> _guardianExams = [];
  List<Map<String, dynamic>> get guardianExams => _guardianExams;

  // Class / Standard Timetable State
  bool _isLoadingTimetable = false;
  bool get isLoadingTimetable => _isLoadingTimetable;

  bool _hasSearched = false;
  bool get hasSearched => _hasSearched;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ExamTimetableItem> _timetableItems = [];
  List<ExamTimetableItem> get timetableItems => _timetableItems;

  // Teacher's Own Subjects Timetable State
  bool _isLoadingOwnSubjects = false;
  bool get isLoadingOwnSubjects => _isLoadingOwnSubjects;

  bool _hasSearchedOwnSubjects = false;
  bool get hasSearchedOwnSubjects => _hasSearchedOwnSubjects;

  String? _ownSubjectsErrorMessage;
  String? get ownSubjectsErrorMessage => _ownSubjectsErrorMessage;

  List<ExamTimetableItem> _ownSubjectsItems = [];
  List<ExamTimetableItem> get ownSubjectsItems => _ownSubjectsItems;

  // Guardian Student Timetable State
  bool _isLoadingStudentTimetable = false;
  bool get isLoadingStudentTimetable => _isLoadingStudentTimetable;

  bool _hasSearchedStudentTimetable = false;
  bool get hasSearchedStudentTimetable => _hasSearchedStudentTimetable;

  String? _studentErrorMessage;
  String? get studentErrorMessage => _studentErrorMessage;

  List<ExamTimetableItem> _studentTimetableItems = [];
  List<ExamTimetableItem> get studentTimetableItems => _studentTimetableItems;

  /// Fetch available exam titles
  Future<void> fetchExamTitles({bool forGuardian = false}) async {
    _isLoadingTitles = true;
    notifyListeners();

    try {
      final response = await _services.fetchExamTitles(
        forGuardian: forGuardian,
      );
      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        List<dynamic>? listData;
        if (rawData is List) {
          listData = rawData;
        } else if (rawData is Map && rawData['data'] is List) {
          listData = rawData['data'] as List;
        }

        if (listData != null) {
          _examTitles = listData
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
    } catch (e) {
      log("Error fetching exam titles: $e");
      if (_examTitles.isEmpty) {
        _examTitles = const ['PT', 'Term', 'Internal', 'Model'];
      }
    } finally {
      _isLoadingTitles = false;
      notifyListeners();
    }
  }

  /// Fetch all exams (terms) for guardian view
  Future<void> fetchGuardianExams() async {
    _isLoadingGuardianExams = true;
    notifyListeners();

    try {
      final response = await _services.fetchAllExamsForGuardian();
      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        List<dynamic>? dataList;
        if (rawData is Map && rawData['data'] is List) {
          dataList = rawData['data'] as List;
        } else if (rawData is List) {
          dataList = rawData;
        }

        if (dataList != null) {
          _guardianExams = dataList
              .whereType<Map>()
              .map<Map<String, dynamic>>(
                (item) => {
                  'id': item['id'] is int
                      ? item['id']
                      : int.tryParse(item['id'].toString()) ?? 0,
                  'exam_name': (item['exam_name'] ?? '').toString(),
                  'education_year': (item['education_year'] ?? '').toString(),
                },
              )
              .where((item) => (item['id'] as int) > 0)
              .toList();
        }
      }
    } catch (e) {
      log("Error fetching guardian exams: $e");
    } finally {
      _isLoadingGuardianExams = false;
      notifyListeners();
    }
  }

  /// Fetch exam timetable for the selected standard, title, and examId
  Future<void> fetchExamTimetable({
    required int standard,
    required String title,
    required int examId,
  }) async {
    _isLoadingTimetable = true;
    _hasSearched = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _services.fetchExamTimetableByStandard(
        standard: standard,
        title: title,
        examId: examId,
        limit: 100,
      );

      if (response.statusCode == 200 && response.data != null) {
        _timetableItems = _parseAndSortTimetableItems(response.data);
      } else {
        _timetableItems = [];
        _errorMessage = "Unable to load exam timetable.";
      }
    } catch (e) {
      log("Error fetching exam timetable: $e");
      _timetableItems = [];
      _errorMessage = "Failed to load exam timetable. Please try again.";
    } finally {
      _isLoadingTimetable = false;
      notifyListeners();
    }
  }

  /// Fetch exam timetable for the teacher's own subjects by examId and title
  Future<void> fetchOwnSubjectsExamTimetable({
    required int examId,
    required String title,
  }) async {
    _isLoadingOwnSubjects = true;
    _hasSearchedOwnSubjects = true;
    _ownSubjectsErrorMessage = null;
    notifyListeners();

    try {
      final response = await _services.fetchExamTimetableByOwnSubjects(
        examId: examId,
        title: title,
        limit: 100,
      );

      if (response.statusCode == 200 && response.data != null) {
        _ownSubjectsItems = _parseAndSortTimetableItems(response.data);
      } else {
        _ownSubjectsItems = [];
        _ownSubjectsErrorMessage = "Unable to load your subjects timetable.";
      }
    } catch (e) {
      log("Error fetching own subjects exam timetable: $e");
      _ownSubjectsItems = [];
      _ownSubjectsErrorMessage =
          "Failed to load your subjects timetable. Please try again.";
    } finally {
      _isLoadingOwnSubjects = false;
      notifyListeners();
    }
  }

  /// Fetch exam timetable for a student (guardian view) by studentId, examId, and title
  Future<void> fetchStudentExamTimetable({
    required int studentId,
    required int examId,
    required String title,
  }) async {
    _isLoadingStudentTimetable = true;
    _hasSearchedStudentTimetable = true;
    _studentErrorMessage = null;
    notifyListeners();

    try {
      final response = await _services.fetchExamTimetableByStudentId(
        studentId: studentId,
        examId: examId,
        title: title,
        limit: 100,
      );

      if (response.statusCode == 200 && response.data != null) {
        _studentTimetableItems = _parseAndSortTimetableItems(response.data);
      } else {
        _studentTimetableItems = [];
        _studentErrorMessage = "Unable to load exam timetable.";
      }
    } catch (e) {
      log("Error fetching student exam timetable: $e");
      _studentTimetableItems = [];
      _studentErrorMessage =
          "Failed to load exam timetable. Please try again.";
    } finally {
      _isLoadingStudentTimetable = false;
      notifyListeners();
    }
  }

  List<ExamTimetableItem> _parseAndSortTimetableItems(dynamic data) {
    List<ExamTimetableItem> items = [];

    if (data is Map<String, dynamic>) {
      final parsed = ExamTimetableResponse.fromJson(data);
      items = List<ExamTimetableItem>.from(parsed.data);
    } else if (data is List) {
      items = data
          .whereType<Map<String, dynamic>>()
          .map(ExamTimetableItem.fromJson)
          .toList();
    }

    // Filter out trashed items and sort chronologically by exam_date, then standard
    items = items.where((item) => !item.trash).toList();
    items.sort((a, b) {
      final dateA = a.parsedExamDate;
      final dateB = b.parsedExamDate;
      if (dateA != null && dateB != null) {
        final cmp = dateA.compareTo(dateB);
        if (cmp != 0) return cmp;
      } else if (dateA != null) {
        return -1;
      } else if (dateB != null) {
        return 1;
      }
      final stdCmp = a.standard.compareTo(b.standard);
      if (stdCmp != 0) return stdCmp;
      return a.id.compareTo(b.id);
    });

    return items;
  }

  void resetTimetable() {
    _timetableItems = [];
    _hasSearched = false;
    _errorMessage = null;
    _ownSubjectsItems = [];
    _hasSearchedOwnSubjects = false;
    _ownSubjectsErrorMessage = null;
    notifyListeners();
  }

  void resetStudentTimetable() {
    _studentTimetableItems = [];
    _hasSearchedStudentTimetable = false;
    _studentErrorMessage = null;
    notifyListeners();
  }
}
