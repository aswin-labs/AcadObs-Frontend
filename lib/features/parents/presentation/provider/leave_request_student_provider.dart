import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/parents/data/services/leave_request_service.dart';
import 'package:acadobs/features/teacher/data/models/grouped_leave_request.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class StudentLeaveRequestProvider extends ChangeNotifier {
  // ────────────────────────────────
  // State variables
  // ────────────────────────────────
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  bool _isFileUploading = false;
  bool get isFileUploading => _isFileUploading;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  int _leaveNotificationCount = 0;
  int get leaveNotificationCount => _leaveNotificationCount;

  String _filterStatus = "all";
  String get filterStatus => _filterStatus;

  // ────────────────────────────────
  // Leave request data
  // ────────────────────────────────
  final List<LeaveModel> _leaveRequests = [];
  final List<GroupedLeaveRequest> _studentLeaves = [];

  List<GroupedLeaveRequest> get studentLeaves => _studentLeaves;

  int _currentPage = 1;
  int _totalPages = 1;
  bool _isFetchedOnce = false;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  bool get hasMore => _currentPage < _totalPages;

  // ────────────────────────────────
  // Upload progress handler
  // ────────────────────────────────
  void _setUploadProgress(int sent, int total) {
    if (total != -1) {
      _uploadProgress = sent / total;
      _isFileUploading = true;
      notifyListeners();
    }
  }

  // ────────────────────────────────
  // Filtered leave list
  // ────────────────────────────────
  List<LeaveModel> get leaveRequests {
    if (_filterStatus == "all") return _leaveRequests;
    return _leaveRequests
        .where((leave) => leave.status == _filterStatus)
        .toList();
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  // ────────────────────────────────
  // Grouped leave getters
  // ────────────────────────────────
  List<LeaveModel> get todayLeave => _filterLeavesByDateOffset(0);
  List<LeaveModel> get yesterdayLeave => _filterLeavesByDateOffset(1);
  List<LeaveModel> get earlierLeave => _filterEarlierLeaves();

  List<LeaveModel> _filterLeavesByDateOffset(int daysAgo) {
    final targetDate = DateTime.now().subtract(Duration(days: daysAgo));
    return _leaveRequests.where((leave) {
        final createdAt = leave.createdAt;
        if (createdAt == null) return false;
        return createdAt.year == targetDate.year &&
            createdAt.month == targetDate.month &&
            createdAt.day == targetDate.day;
      }).toList()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  List<LeaveModel> _filterEarlierLeaves() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return _leaveRequests.where((leave) {
        final createdAt = leave.createdAt;
        if (createdAt == null) return false;
        final createdDate = DateTime(
          createdAt.year,
          createdAt.month,
          createdAt.day,
        );
        return createdDate.isBefore(yesterday);
      }).toList()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  // ────────────────────────────────
  // Fetch all student leave requests (Parent/Student)
  // ────────────────────────────────
  Future<void> fetchAllStudentLeaveRequests({
    bool loadMore = false,
    bool forceRefresh = false,
    required int studentId,
    bool forParent = true,
  }) async {
    _isLoading = true;

    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _leaveRequests.clear();
      }

      final response = await StudentLeaveRequestServices()
          .fetchAllStudentLeaveRequests(
            pageNo: _currentPage,
            studentId: studentId,
            forParent: forParent,
          );

      log("API Response: ${response.data}, Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List leavesJson = data['leaves'] ?? [];
        final fetchedLeaves =
            leavesJson.map((e) => LeaveModel.fromJson(e)).toList();
        _leaveRequests.addAll(fetchedLeaves);
      } else {
        throw Exception('Failed to fetch leaves: ${response.statusCode}');
      }
    } catch (e) {
      log("Error fetching student leaves: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────
  // Create a new student leave request
  // ────────────────────────────────
  Future<void> createStudentLeaveRequest({
    required BuildContext context,
    required String fromDate,
    required String toDate,
    required String leaveType,
    required String reason,
    required int studentId,
    required String leaveDuration,
    String? halfSection,
  }) async {
    _isLoadingTwo = true;
    _isFileUploading = false;
    _uploadProgress = 0.0;
    PopupLoader.show(context, message: "Sending Leave Request...");
    notifyListeners();

    try {
      final response = await StudentLeaveRequestServices()
          .createStudentLeaveRequest(
            context: context,
            fromDate: fromDate,
            toDate: toDate,
            leaveType: leaveType,
            reason: reason,
            studentId: studentId,
            leaveDuration: leaveDuration,
            halfSection: halfSection,
            onSendProgress: _setUploadProgress,
          );

      if (response.statusCode == 201) {
        await fetchAllStudentLeaveRequests(
          forceRefresh: true,
          studentId: studentId,
        );
        if (!context.mounted) return;
        PopupLoader.hide(context);
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Leave Request Submitted Successfully",
          type: SnackbarType.success,
        );
      } else if (response.statusCode == 400) {
        if (!context.mounted) return;
        PopupLoader.hide(context);
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: response.data["error"],
          type: SnackbarType.failure,
        );
      }

      log("Response status: ${response.statusCode}");
    } catch (e) {
      _isFileUploading = false;
      _uploadProgress = 0.0;
      log("Error creating leave request: $e");

      if (e is DioException) {
        log("Backend response: ${e.response?.data}");
      }
    } finally {
      _isLoadingTwo = false;
      _isFileUploading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────
  // Fetch leave requests for class teacher
  // ────────────────────────────────
  Future<void> getStudentLeaveRequestsForClassTeacher({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoading = true;

    try {
      if (loadMore) {
        if (_currentPage >= _totalPages) {
          _isLoading = false;
          return;
        }
        _currentPage++;
      } else {
        _currentPage = 1;
        _studentLeaves.clear();
        _isFetchedOnce = false;
      }

      final response = await StudentLeaveRequestServices()
          .getStudentLeaveRequestsForClassTeacher(pageNo: _currentPage);

      if (response.statusCode == 200) {
        await getLeaveRequestNotification();

        final data = response.data;
        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List leavesJson = data['leaveRequests'];
        final List<GroupedLeaveRequest> fetchedLeaves =
            leavesJson.map((e) => GroupedLeaveRequest.fromJson(e)).toList();

        _studentLeaves.addAll(fetchedLeaves);
        _isFetchedOnce = true;
      } else {
        throw Exception("Failed to fetch leaves: ${response.statusCode}");
      }
    } catch (e) {
      log("Error fetching class teacher leaves: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ────────────────────────────────
  // Get notification count for leave requests
  // ────────────────────────────────
  Future<void> getLeaveRequestNotification() async {
    try {
      final response =
          await StudentLeaveRequestServices().getLeaveRequestNotification();

      if (response.statusCode == 200) {
        final data = response.data;
        _leaveNotificationCount = data['studentLeaveRequestCount'] ?? 0;
        log("Leave notification count: $_leaveNotificationCount");
      }
    } catch (e) {
      log("Error fetching leave request notifications: $e");
    } finally {
      notifyListeners();
    }
  }
}
