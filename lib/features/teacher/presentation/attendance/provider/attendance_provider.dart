import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/teacher/data/models/attendance_by_teacher_model.dart';
import 'package:acadobs/features/teacher/data/models/attendance_recorded_data_model.dart';
import 'package:acadobs/features/teacher/data/services/attendance_services.dart';
import 'package:acadobs/shared/models/student_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  final List<AttendanceByTeacher> _attendanceByTeacher = [];
  List<AttendanceByTeacher> get attendanceByTeacher => _attendanceByTeacher;

  AttendanceRecordedData? attendanceRecordedData;

  List<StudentProfile> _students = [];
  List<StudentProfile> get students => _students;

  List<int> _studentIds = [];
  List<int> get studentIds => _studentIds;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  final int _teacherId = 3;

  // set attendance
  final Map<int, Map<String, String?>> _attendanceData = {};

  Future<void> fetchAttendanceByClassIdAndDate({
    required BuildContext context,
    required int classId,
    required String date,
    required int period,
  }) async {
    _isLoading = true;
    _students.clear();
    attendanceRecordedData == null;
    try {
      final response = await AttendanceServices()
          .fetchAttendanceByClassIdAndDate(
            classId: classId,
            date: date,
            period: period,
          );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'recorded') {
          log("Attendance already taken");
          attendanceRecordedData = AttendanceRecordedData.fromJson(data);
          if (!context.mounted) return;
          CustomSnackbar.show(
            context,
            message: "Attendance Already Taken",
            type: SnackbarType.info,
          );
        } else {
          _students =
              (data['students'] as List<dynamic>)
                  .map((result) => StudentProfile.fromJson(result))
                  .toList();
          _studentIds = _students.map((e) => e.id).toList();
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setAttendance(int studentId, String status, [String? remarks]) {
    _attendanceData[studentId] = {'status': status, 'remarks': remarks};
    notifyListeners();
  }

  void setRemarks(int studentId, String? remarks) {
    if (_attendanceData.containsKey(studentId)) {
      _attendanceData[studentId]!['remarks'] = remarks;
    } else {
      _attendanceData[studentId] = {'status': '', 'remarks': remarks};
    }
    notifyListeners();
  }

  String? getStatus(int studentId) {
    return _attendanceData[studentId]?['status'];
  }

  String? getRemarks(int studentId) {
    return _attendanceData[studentId]?['remarks'];
  }

  List<Map<String, dynamic>> getAttendanceList() {
    return _attendanceData.entries.map((entry) {
      return {
        'student_id': entry.key,
        'status': entry.value['status'],
        'remarks': entry.value['remarks'],
      };
    }).toList();
  }

  // mark all present
   void markAllPresent() {
    for (var id in _studentIds) {
      setAttendance(id, "Present");
    }
    notifyListeners();
  }

  // present count
  int get presentCount {
    return _attendanceData.entries
        .where(
          (entry) =>
              entry.value['status'] == 'Present' ||
              entry.value['status'] == 'Late',
        )
        .length;
  }

  // absent count
  int get absentCount {
    return _attendanceData.entries
        .where((entry) => entry.value['status'] == 'Absent')
        .length;
  }

  void clearAllAttendance() {
    _attendanceData.clear();
    notifyListeners();
  }

  // Submit attendance
  Future<void> submitAttendance({
    required BuildContext context,
    required int classId,
    required int period,
    required String date,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await AttendanceServices().submitAttendance(
        data: {
          "teacher_id": _teacherId,
          "period": period,
          "class_id": classId,
          "date": date,
          "students": getAttendanceList(),
        },
      );
      if (response.statusCode == 201) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Attendance Submitted Successfully",
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  //fetch teacher taken attendance
  Future<void> fetchAttendanceByTeacher({
    String? date,
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
        _attendanceByTeacher.clear();
        _isFetchedOnce = false;
      }
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final response = await AttendanceServices().fetchAttendanceByTeacher(
        pageNo: _currentPage,
        date: date ?? currentDate,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];
        List<AttendanceByTeacher> attendanceJson =
            (response.data['attendance'] as List<dynamic>)
                .map((result) => AttendanceByTeacher.fromJson(result))
                .toList();
        _attendanceByTeacher.addAll(attendanceJson);
        _isFetchedOnce = true;
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
