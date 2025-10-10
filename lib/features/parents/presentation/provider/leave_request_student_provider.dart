import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/parents/data/services/leave_request_service.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class StudentLeaveRequestProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  double _uploadProgress = 0.0;
  double get uploadProgress => _uploadProgress;

  bool _isFileUploading = false;
  bool get isFileUploading => _isFileUploading;

  void _setUploadProgress(int sent, int total) {
    if (total != -1) {
      _uploadProgress = sent / total;
      _isFileUploading = true;
      notifyListeners();
    }
  }

  final List<LeaveModel> _leaveRequests = [];
  // List<LeaveModel> get leaveRequests => _leaveRequests;

  String _filterStatus = "all";
  String get filterStatus => _filterStatus;
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

  //today leave request
  List<LeaveModel> get todayLeave =>
      _leaveRequests.where((e) {
          final createdAt = e.createdAt;
          if (createdAt == null) return false;
          final now = DateTime.now();
          return now.year == createdAt.year &&
              now.month == createdAt.month &&
              now.day == createdAt.day;
        }).toList()
        ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

  //yeasterday leave request
  List<LeaveModel> get yesterdayLeave =>
      _leaveRequests.where((e) {
          final createdAt = e.createdAt;
          if (createdAt == null) return false;
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          return yesterday.year == createdAt.year &&
              yesterday.month == createdAt.month &&
              yesterday.day == createdAt.day;
        }).toList()
        ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

  //earlier leave request
  List<LeaveModel> get earlierLeave {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return _leaveRequests.where((e) {
        final createdAt = e.createdAt;
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

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;


  // Fetch Staff Duties
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

        final List leavesJson = data['leaves'];

        final List<LeaveModel> fetchedLeaves =
            leavesJson
                .map((jsonItem) => LeaveModel.fromJson(jsonItem))
                .toList();
        _leaveRequests.addAll(fetchedLeaves);
      } else {
        throw Exception('Failed to fetch Leaves: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // create leave request
  Future<void> createStudentLeaveRequest({
    required BuildContext context,
    required String fromDate,
    required String toDate,
    required String leaveType,
    required String reason,
    required int studentId,
    required String leaveDuration,
    String? halfSection
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
            onSendProgress: _setUploadProgress,
            leaveDuration: leaveDuration,
            halfSection:halfSection
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
      }
      if (response.statusCode == 400) {
        if (!context.mounted) return;
        PopupLoader.hide(context);
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: response.data["error"],
          type: SnackbarType.failure,
        );
      }
      log(response.statusCode.toString());
      log('response: ${response.toString()}');
    } catch (e) {
      _isFileUploading = false;
      _uploadProgress = 0.0;
      log(e.toString());
      if (e is DioException) {
        log("Backend response data: ${e.response?.data}");
      }
      notifyListeners();
    } finally {
      _isLoadingTwo = false;
      _isFileUploading = false;
      notifyListeners();
    }
  }

  bool _isFetchedOnce = false;
  bool get isFetchedOnce => _isFetchedOnce;

  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  //student leave request for the class teacher
  Future<void> getStudentLeaveRequestsForClassTeacher({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;
    _isLoading = true;
    notifyListeners();
    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _leaveRequests.clear();
        _isFetchedOnce = false;
      }
      final response =
          await StudentLeaveRequestServices()
              .getStudentLeaveRequestsForClassTeacher();
      log(response.toString());
      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        // final List leavesJson = data['leaves'];
        final List<dynamic> leavesJson = data['leaveRequests'] ?? [];

        final List<LeaveModel> fetchedLeaves =
            leavesJson
                .map((jsonItem) => LeaveModel.fromJson(jsonItem))
                .toList();
        _leaveRequests.addAll(fetchedLeaves);
        _isFetchedOnce = true;
      } else {
        throw Exception("failed to fetch leaves:${response.statusCode}");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
