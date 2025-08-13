import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_model.dart';
import 'package:acadobs/features/teacher/data/services/attendance_services.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  bool _isRestoring = false;
  bool get isRestoring => _isRestoring;

  final List<AttendanceModel> _attendanceByTeacher = [];
  List<AttendanceModel> get attendanceByTeacher => _attendanceByTeacher;

  AttendanceModel? recordedAttendance;

  bool _isAttendanceAlreadyTaken = false;
  bool get isAttendanceAlreadyTaken => _isAttendanceAlreadyTaken;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  List<int> _studentIds = [];
  List<int> get studentIds => _studentIds;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;
  bool get hasFetchedOnce => _isFetchedOnce;

  final int _teacherId = 3;

  final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  // set attendance
  final Map<int, Map<String, String?>> _uploadingAttendanceData = {};

  final List<Map<String, dynamic>> _editedAttendanceList = [];
  List<Map<String, dynamic>> get editedAttendanceList => _editedAttendanceList;

  Future<void> fetchAttendanceByClassIdAndDate({
    required BuildContext context,
    required int classId,
    required String date,
    required int period,
    bool forRestoring = false,
  }) async {
    _isLoading = true;
    _students.clear();
    recordedAttendance = null;
    _isAttendanceAlreadyTaken = false;

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
          _isAttendanceAlreadyTaken = true;
          recordedAttendance = AttendanceModel.fromJson(data['attendance']);
          if (!context.mounted) return;
          if (forRestoring) {
            log("Attendance fetched after restoring");
          } else {
            final isInTrash = recordedAttendance?.trash == true;

            CustomSnackbar.show(
              context,
              message:
                  isInTrash
                      ? "This attendance record has been deleted."
                      : "Attendance already recorded.",
              type: isInTrash ? SnackbarType.failure : SnackbarType.info,
            );
          }
        } else {
          _students =
              (data['students'] as List<dynamic>)
                  .map((e) => StudentModel.fromJson(e))
                  .toList();
          _studentIds = _students.map((e) => e.id).toList();
        }
      }
    } catch (e, stackTrace) {
      log("Error fetching attendance: $e");
      log(stackTrace.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // attendance by Id
  Future<void> fetchAttendanceById({required int attendanceId}) async {
    _isLoading = true;
    recordedAttendance = null;
    try {
      final response = await AttendanceServices().fetchAttendanceById(
        attendanceId: attendanceId,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        recordedAttendance = AttendanceModel.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setAttendance(int studentId, String status, [String? remarks]) {
    _uploadingAttendanceData[studentId] = {
      'status': status,
      'remarks':
          status == 'present' ? null : remarks, // Clear remarks for Present
    };
    notifyListeners();
  }

  void setRemarks(int studentId, String? remarks) {
    final currentStatus = _uploadingAttendanceData[studentId]?['status'];

    if (currentStatus == 'Present') return; // Don't allow remarks for Present

    if (_uploadingAttendanceData.containsKey(studentId)) {
      _uploadingAttendanceData[studentId]!['remarks'] = remarks;
    } else {
      _uploadingAttendanceData[studentId] = {'status': '', 'remarks': remarks};
    }
    notifyListeners();
  }

  String? getStatus(int studentId) {
    return _uploadingAttendanceData[studentId]?['status'];
  }

  String? getRemarks(int studentId) {
    final data = _uploadingAttendanceData[studentId];
    if (data == null) return null;
    if (data['status'] == 'present') return null;
    return data['remarks'];
  }

  List<Map<String, dynamic>> getAttendanceList() {
    return _uploadingAttendanceData.entries.map((entry) {
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
    return _uploadingAttendanceData.entries
        .where(
          (entry) =>
              entry.value['status'] == 'Present' ||
              entry.value['status'] == 'Late',
        )
        .length;
  }

  // absent count
  int get absentCount {
    return _uploadingAttendanceData.entries
        .where((entry) => entry.value['status'] == 'Absent')
        .length;
  }

  void clearAllAttendance() {
    _uploadingAttendanceData.clear();
    notifyListeners();
  }

  // Submit attendance
  Future<void> submitAttendance({
    required BuildContext context,
    required int classId,
    required int period,
    required String date,
    int? subjectId,
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
          "subject_id": subjectId ?? 0,
          "students": getAttendanceList(),
        },
      );
      if (response.statusCode == 201) {
        await fetchAttendanceByTeacher(forceRefresh: true);
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
  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> fetchAttendanceByTeacher({
    String? date,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    // If not loading more, check if already fetched once
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (!loadMore && date != null) {
        setSelectedDate(DateFormat('yyyy-MM-dd').parse(date));
      }

      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        // _attendanceByTeacher.clear();
        _isFetchedOnce = false;
      }
      if (!loadMore) {
        _attendanceByTeacher.clear(); // 🔄 Move here!
      }

      final response = await AttendanceServices().fetchAttendanceByTeacher(
        pageNo: _currentPage,
        date:
            date ??
            DateFormat('yyyy-MM-dd').format(_selectedDate ?? DateTime.now()),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        List<AttendanceModel> attendanceList =
            (data['attendance'] as List)
                .map((e) => AttendanceModel.fromJson(e))
                .toList();

        _attendanceByTeacher.addAll(attendanceList);
        _isFetchedOnce = true;
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Edit attendance details
  Future<void> editAttendanceDetails({
    required BuildContext context,
    required int attendanceId,
    required int period,
    required String date,
    required int subjectId,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await AttendanceServices().editAttendanceDetails(
        attendanceId: attendanceId,
        period: period,
        date: date,
        subjectId: subjectId,
      );
      if (response.statusCode == 200) {
        await fetchAttendanceByTeacher(forceRefresh: true);
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Attendance Details Saved",
          type: SnackbarType.success,
        );
      }
      if (response.statusCode == 400) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "${response.data["error"]}. Can't update details",
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  //************* Edit Bulk Attendance ******************//

  // Set Edited Attendance
  void setEditedAttendance(int attendanceId, String status, [String? remarks]) {
    final finalRemarks =
        status.toLowerCase() == "present"
            ? null
            : remarks ?? _editedRemarksMap[attendanceId] ?? "";

    final index = _editedAttendanceList.indexWhere(
      (e) => e['id'] == attendanceId,
    );
    final entry = {
      "id": attendanceId,
      "status": status,
      "remarks": finalRemarks,
    };

    if (index != -1) {
      _editedAttendanceList[index] = entry;
    } else {
      _editedAttendanceList.add(entry);
    }

    notifyListeners();
  }

  String? getEditedStatus(int attendanceId) {
    final match = _editedAttendanceList.firstWhere(
      (e) => e['id'] == attendanceId,
      orElse: () => {},
    );
    return match['status']?.toString().isNotEmpty == true
        ? match['status']
        : null;
  }

  final Map<int, String> _editedRemarksMap = {};

  void setEditedRemarks(int attendanceId, String? remarks) {
    final currentStatus = getEditedStatus(attendanceId);
    if (currentStatus?.toLowerCase() == "present") return; // ignore if present

    if (remarks != null) {
      _editedRemarksMap[attendanceId] = remarks;
    }
  }

  String? getEditedRemarks(int attendanceId) {
    final currentStatus = getEditedStatus(attendanceId);
    if (currentStatus?.toLowerCase() == "present") return null;
    return _editedRemarksMap[attendanceId];
  }

  // Edit Bulk attendance
  Future<void> editBulkAttendance({
    required BuildContext context,
    required int attendanceId,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      log("Edited list:${_editedAttendanceList.toString()}");
      final response = await AttendanceServices().editBulkAttendance(
        attendanceId: attendanceId,
        attendanceList: _editedAttendanceList,
      );
      if (response.statusCode == 200) {
        await fetchAttendanceByTeacher(forceRefresh: true);
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Attendance Edited Successfully",
          type: SnackbarType.success,
        );
        context.pushNamed(
          RouteConstants.bottomNavScreen,
          extra: UserType.teacher,
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Delete an attendance
  Future<void> deleteAttendance(context, {required int attendanceId}) async {
    try {
      final response = await AttendanceServices().deleteAttendance(
        attendanceId: attendanceId,
      );
      if (response.statusCode == 200) {
        CustomSnackbar.show(
          context,
          message: 'Attendance Deleted',
          type: SnackbarType.failure,
        );
      } else {
        log('Failed to delete subject: ${response.statusCode}');
      }
      Navigator.pop(context);
      _attendanceByTeacher.removeWhere(
        (attendance) => attendance.id == attendanceId,
      );
      notifyListeners();
    } catch (e) {
      log('Error deleting subject: $e');
    }
  }

  // Restore attendance
  Future<bool> restoreAttendance({
    required BuildContext context,
    required int attendanceId,
  }) async {
    _isRestoring = true;
    notifyListeners();

    try {
      final response = await AttendanceServices().restoreAttendance(
        attendanceId: attendanceId,
      );

      if (response.statusCode == 200) {
        await fetchAttendanceByTeacher(forceRefresh: true);
        log("Attendance restored successfully");
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: 'Attendance restored successfully',
            type: SnackbarType.success,
          );
        }
        return true;
      }

      return false;
    } catch (e) {
      log("Restore failed: $e");
      return false;
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }
}
