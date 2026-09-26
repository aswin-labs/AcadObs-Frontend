import 'dart:developer';
import 'dart:io';

import 'package:acadobs/features/notices/data/models/notice_model.dart';
import 'package:acadobs/features/students/data/models/student_co_scholastic_assessment_model.dart';
import 'package:acadobs/features/students/data/models/student_competency_assessment_model.dart';
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

  bool _isLoadingCompetency = false;
  bool get isLoadingCompetency => _isLoadingCompetency;

  bool _hasCompetencyAssessment = false;
  bool get hasCompetencyAssessment => _hasCompetencyAssessment;

  List<StudentCompetencyAssessmentItem> _competencyAssessments = [];
  List<StudentCompetencyAssessmentItem> get competencyAssessments => _competencyAssessments;

  List<GroupedCompetency> _groupedCompetencies = [];
  List<GroupedCompetency> get groupedCompetencies => _groupedCompetencies;

  List<StudentCompetencyExamInfo> _competencyExams = [];
  List<StudentCompetencyExamInfo> get competencyExams => _competencyExams;

  bool _isLoadingCoScholastic = false;
  bool get isLoadingCoScholastic => _isLoadingCoScholastic;

  List<StudentCoScholasticAssessmentItem> _coScholasticAssessments = [];
  List<StudentCoScholasticAssessmentItem> get coScholasticAssessments =>
      _coScholasticAssessments;

  List<GroupedCoScholasticArea> _groupedCoScholasticAreas = [];
  List<GroupedCoScholasticArea> get groupedCoScholasticAreas =>
      _groupedCoScholasticAreas;

  List<StudentCoScholasticExamInfo> _coScholasticExams = [];
  List<StudentCoScholasticExamInfo> get coScholasticExams => _coScholasticExams;

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
    _isLoadingCompetency = false;
    _hasCompetencyAssessment = false;
    _competencyAssessments.clear();
    _groupedCompetencies.clear();
    _competencyExams.clear();
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
  Future<void> fetchStudentDetails({
    required int studentId,
    required bool forStaff,
  }) async {
    if (_individualStudent?.id != studentId) {
      _individualStudent = null;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final response = await StudentServices().fetchStudentDetails(
        studentId: studentId,
        forStaff: forStaff,
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

  int _attendanceCount = 0;
  int get attendanceCount => _attendanceCount;

  List<String> _status = [];
  List<String> get status => _status;

  Future<void> fetchAttendanceByDate({
    required int studentId,
    required String date,
    required bool forStaff,
  }) async {
    try {
      _isLoading = true;

      _attendanceCount = 0;
      _status = [];
      log(" Sending request for studentId=$studentId, date=$date");

      final response = await StudentServices().fetchAttendanceByDate(
        studentId: studentId,
        date: date,
        forStaff: forStaff,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        log(" Attendance API response: $data");
        _attendanceCount = data['attendance_count'] ?? 0;
        log(" attendanceCount = $_attendanceCount");

        _status = List<String>.filled(_attendanceCount, "NA");

        final List<dynamic> attendanceList = data['attendance'] ?? [];
        log("attendanceList = $attendanceList");

        for (final item in attendanceList) {
          final dynamic p = item['Attendance']?['period'];
          final int? period = (p is int) ? p : int.tryParse('$p');
          final String st = (item['status'] ?? 'NA').toString().toLowerCase();

          if (period != null && period >= 1 && period <= _attendanceCount) {
            _status[period - 1] = st;
          }
        }
        log("status list: $_status");
      } else {
        log(
          " Non-200 response: ${response.statusCode} → keeping reset state (no attendance)",
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetAttendance() {
    log("Resetting attendance: _attendanceCount = 0, _status = []");
    _isLoading = true;
    _attendanceCount = 0;
    _status = [];
    // notifyListeners();
  }

  //////////////
  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  final List<NoticeModel> _notices = [];
  List<NoticeModel> get notices => _notices;

  Future<void> fetchNoticeByStudentId({
    bool loadMore = false,
    bool forceRefresh = false,
    required int studentId,
  }) async {
    _isLoading = true;

    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _notices.clear();
      }
      final response = await StudentServices().fetchNoticeByStudentId(
        pageNo: _currentPage,
        studentId: studentId,
      );
      log("API Response: ${response.data}, Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List noticeJson = data['notices'];

        final List<NoticeModel> fetchedNotices =
            noticeJson
                .map((jsonItem) => NoticeModel.fromJson(jsonItem))
                .toList();
        _notices.addAll(fetchedNotices);
      } else {
        throw Exception('Failed to fetch Notices: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //update student address
  Future<void> updateStudentAddress({
    required int studentId,
    String? address,
  }) async {
    _isLoading = true;
    try {
      final response = await StudentServices().updateStudentProfile(
        studentId: studentId,
        address: address,
      );
      log("API Response: ${response.data}, Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        await fetchStudentDetails(studentId: studentId, forStaff: false);
        log('successfully updated');
        final data = response.data;
        _individualStudent = StudentModel.fromJson(data);
      } else {
        throw Exception(
          'Failed to update student address: ${response.statusCode}',
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //update student profile picture
  Future<void> updateProfilePhoto({
    required File image,
    required bool forStaff,
    required int studentId,
  }) async {
    _isLoading = true;
    notifyListeners();
    log(" Starting profile photo upload...");

    try {
      final response = await StudentServices().updateProfilePhoto(
        forStaff: forStaff,
        image: image,
        studentId: studentId,
      );
      log("🟢 Upload response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        await fetchStudentDetails(studentId: studentId, forStaff: forStaff);
        log("Profile photo updated successfully, fetching updated profile...");
        log(" Profile photo updated successfully");
        // forStaff ? await fetchProfileStaff() : await fetchProfileGuardian();
      } else {
        log(" Failed to update profile photo: ${response.statusCode}");
      }
    } catch (e, st) {
      log("Error updating profile photo: $e");
      log("Stack trace: $st");
    } finally {
      _isLoading = false;
      notifyListeners();
      log(" Done updating profile photo");
    }
  }

  // Fetch competency assessments by student id
  Future<void> fetchCompetencyAssessment({
    required int studentId,
    required bool forStaff,
  }) async {
    _isLoadingCompetency = true;
    notifyListeners();

    try {
      final response =
          await StudentServices().fetchCompetencyAssessmentByStudentId(
        studentId: studentId,
        forStaff: forStaff,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data['data'] ?? response.data;
        if (rawData is List && rawData.isNotEmpty) {
          _competencyAssessments =
              StudentCompetencyAssessmentItem.fromJsonList(rawData);
          _groupedCompetencies =
              StudentCompetencyHelper.groupAssessments(_competencyAssessments);
          _competencyExams =
              StudentCompetencyHelper.getUniqueExams(_competencyAssessments);
          _hasCompetencyAssessment = _competencyAssessments.isNotEmpty;
        } else {
          _competencyAssessments = [];
          _groupedCompetencies = [];
          _competencyExams = [];
          _hasCompetencyAssessment = false;
        }
      } else {
        _competencyAssessments = [];
        _groupedCompetencies = [];
        _competencyExams = [];
        _hasCompetencyAssessment = false;
      }
    } catch (e) {
      log("Error fetching student competency assessment: $e");
      _competencyAssessments = [];
      _groupedCompetencies = [];
      _competencyExams = [];
      _hasCompetencyAssessment = false;
    } finally {
      _isLoadingCompetency = false;
      notifyListeners();
    }
  }

  // Fetch co-scholastic assessments by student id
  Future<void> fetchCoScholasticAssessment({
    required int studentId,
    required bool forStaff,
  }) async {
    _isLoadingCoScholastic = true;
    notifyListeners();

    try {
      final response =
          await StudentServices().fetchCoScholasticAssessmentByStudentId(
        studentId: studentId,
        forStaff: forStaff,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data['data'] ?? response.data;
        if (rawData is List && rawData.isNotEmpty) {
          _coScholasticAssessments =
              StudentCoScholasticAssessmentItem.fromJsonList(rawData);
          _groupedCoScholasticAreas =
              StudentCoScholasticHelper.groupAssessments(
            _coScholasticAssessments,
          );
          _coScholasticExams =
              StudentCoScholasticHelper.getUniqueExams(
            _coScholasticAssessments,
          );
        } else {
          _coScholasticAssessments = [];
          _groupedCoScholasticAreas = [];
          _coScholasticExams = [];
        }
      } else {
        _coScholasticAssessments = [];
        _groupedCoScholasticAreas = [];
        _coScholasticExams = [];
      }
    } catch (e) {
      log("Error fetching student co-scholastic assessment: $e");
      _coScholasticAssessments = [];
      _groupedCoScholasticAreas = [];
      _coScholasticExams = [];
    } finally {
      _isLoadingCoScholastic = false;
      notifyListeners();
    }
  }
}
