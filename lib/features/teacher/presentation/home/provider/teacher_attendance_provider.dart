import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/teacher/data/models/attendance/staff_attendance_history_model.dart';
import 'package:acadobs/features/teacher/data/services/teacher_attendance_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class TeacherAttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingForChangeStatus = false;
  bool get isLoadingForChangeStatus => _isLoadingForChangeStatus;

  String _todayAttendanceStatus = '';
  String get todayAttendanceStatus => _todayAttendanceStatus;

  // Attendance History state
  List<StaffAttendanceHistoryItem> _historyList = [];
  List<StaffAttendanceHistoryItem> get historyList => _historyList;

  bool _isLoadingHistory = false;
  bool get isLoadingHistory => _isLoadingHistory;

  bool _isFetchingMoreHistory = false;
  bool get isFetchingMoreHistory => _isFetchingMoreHistory;

  int _historyCurrentPage = 1;
  int get historyCurrentPage => _historyCurrentPage;

  int _historyTotalPages = 1;
  int get historyTotalPages => _historyTotalPages;

  int _historyTotalContent = 0;
  int get historyTotalContent => _historyTotalContent;

  String? _historyDateFilter;
  String? get historyDateFilter => _historyDateFilter;

  bool get hasMoreHistory => _historyCurrentPage < _historyTotalPages;

  // get today attendance status
  Future<void> getTodayAttendanceStatus() async {
    _isLoading = true;
    _todayAttendanceStatus = '';
    notifyListeners();

    try {
      final response =
          await TeacherAttendanceServices().getTodayAttendanceStatus();
      log("attendance status==========${response.data.toString()}");

      if (response.statusCode == 200) {
        _todayAttendanceStatus = response.data['status'] ?? 'Not Marked';
      }
    } catch (e) {
      log(e.toString());
      _todayAttendanceStatus = 'Not Marked';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch staff attendance history
  Future<void> fetchStaffAttendanceHistory({
    bool refresh = false,
    String? date,
  }) async {
    _isLoadingHistory = true;
    if (refresh) {
      _historyCurrentPage = 1;
      _historyList.clear();
    }
    notifyListeners();

    if (date != null) {
      _historyDateFilter = date.trim().isEmpty ? null : date.trim();
    }

    try {
      final response = await TeacherAttendanceServices().getMyStaffAttendance(
        pageNo: 1,
        date: _historyDateFilter,
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = StaffAttendanceHistoryResponse.fromJson(response.data);
        _historyList = parsed.data;
        _historyCurrentPage = parsed.currentPage;
        _historyTotalPages = parsed.totalPages;
        _historyTotalContent = parsed.totalContent;
      } else {
        _historyList = [];
        _historyCurrentPage = 1;
        _historyTotalPages = 1;
        _historyTotalContent = 0;
      }
    } catch (e) {
      log("Error fetching staff attendance history: $e");
      _historyList = [];
      _historyCurrentPage = 1;
      _historyTotalPages = 1;
      _historyTotalContent = 0;
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  // Load more staff attendance history (pagination)
  Future<void> loadMoreStaffAttendanceHistory() async {
    if (_isLoadingHistory || _isFetchingMoreHistory || !hasMoreHistory) {
      return;
    }

    _isFetchingMoreHistory = true;
    notifyListeners();

    try {
      final nextPage = _historyCurrentPage + 1;
      final response = await TeacherAttendanceServices().getMyStaffAttendance(
        pageNo: nextPage,
        date: _historyDateFilter,
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = StaffAttendanceHistoryResponse.fromJson(response.data);
        _historyList.addAll(parsed.data);
        _historyCurrentPage = parsed.currentPage;
        _historyTotalPages = parsed.totalPages;
        _historyTotalContent = parsed.totalContent;
      }
    } catch (e) {
      log("Error loading more staff attendance history: $e");
    } finally {
      _isFetchingMoreHistory = false;
      notifyListeners();
    }
  }

  // Set date filter
  void setHistoryDateFilter(String? date) {
    _historyDateFilter =
        (date != null && date.trim().isNotEmpty) ? date.trim() : null;
    fetchStaffAttendanceHistory(refresh: true);
  }

  // Clear date filter
  void clearHistoryDateFilter() {
    _historyDateFilter = null;
    fetchStaffAttendanceHistory(refresh: true);
  }

  // Check in attendance
  Future<void> checkInAttendance({
    required BuildContext context,
    required String latitude,
    required String longitude,
    bool showLoader = true,
  }) async {
    _isLoadingForChangeStatus = true;

    if (showLoader) {
      PopupLoader.show(context, message: "Updating status...");
    }

    notifyListeners();

    try {
      final response = await TeacherAttendanceServices().checkInAttendance(
        latitude: latitude,
        longitude: longitude,
      );

      if (!context.mounted) return;

      if (response.statusCode == 201) {
        await getTodayAttendanceStatus();

        if (!context.mounted) return;

        CustomSnackbar.show(
          context,
          message: response.data['message'] ?? "Attendance marked successfully",
          type: SnackbarType.success,
        );
      } else if (response.statusCode == 400) {
        CustomSnackbar.show(
          context,
          message: response.data['message'] ?? "Unable to mark attendance",
          type: SnackbarType.failure,
        );
      } else {
        CustomSnackbar.show(
          context,
          message: response.data['message'] ?? "Unknown error occurred",
          type: SnackbarType.failure,
        );
      }
    } on DioException catch (e) {
      if (!context.mounted) return;

      final response = e.response;

      if (response != null) {
        CustomSnackbar.show(
          context,
          message:
              response.data is Map
                  ? (response.data['message'] ?? 'Something went wrong')
                  : 'Something went wrong',
          type: SnackbarType.failure,
        );
      } else {
        CustomSnackbar.show(
          context,
          message: "Network error. Please check your internet connection.",
          type: SnackbarType.failure,
        );
      }

      log("Dio Error: ${e.message}");
      log("Status Code: ${response?.statusCode}");
      log("Response Data: ${response?.data}");
    } catch (e) {
      if (!context.mounted) return;

      CustomSnackbar.show(
        context,
        message: "Something went wrong",
        type: SnackbarType.failure,
      );

      log("Error sending location: $e");
    } finally {
      if (showLoader && context.mounted) {
        PopupLoader.hide(context);
      }

      _isLoadingForChangeStatus = false;
      notifyListeners();
    }
  }

  // Check out attendance
  Future<void> checkOutAttendance({
    required BuildContext context,
    required String latitude,
    required String longitude,
    bool showLoader = true,
  }) async {
    _isLoadingForChangeStatus = true;

    if (showLoader) {
      PopupLoader.show(context, message: "Updating status...");
    }

    notifyListeners();

    try {
      final response = await TeacherAttendanceServices().checkOutAttendance(
        latitude: latitude,
        longitude: longitude,
      );

      if (!context.mounted) return;

      if (response.statusCode == 200) {
        await getTodayAttendanceStatus();

        if (!context.mounted) return;

        CustomSnackbar.show(
          context,
          message: response.data['message'] ?? "Checked out successfully",
          type: SnackbarType.success,
        );
      } else if (response.statusCode == 400) {
        CustomSnackbar.show(
          context,
          message: response.data['message'] ?? "Unable to checkout attendance",
          type: SnackbarType.failure,
        );
      } else {
        CustomSnackbar.show(
          context,
          message: response.data['message'] ?? "Unknown error occurred",
          type: SnackbarType.failure,
        );
      }
    } on DioException catch (e) {
      if (!context.mounted) return;

      final response = e.response;

      if (response != null) {
        CustomSnackbar.show(
          context,
          message:
              response.data is Map
                  ? (response.data['message'] ?? "Something went wrong")
                  : "Something went wrong",
          type: SnackbarType.failure,
        );
      } else {
        CustomSnackbar.show(
          context,
          message: "Network error. Please check your internet connection.",
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      if (!context.mounted) return;

      CustomSnackbar.show(
        context,
        message: "Something went wrong",
        type: SnackbarType.failure,
      );

      log("Error checking out attendance: $e");
    } finally {
      if (showLoader && context.mounted) {
        PopupLoader.hide(context);
      }

      _isLoadingForChangeStatus = false;
      notifyListeners();
    }
  }

  // reset attndance status
  void resetAttendance() {
    _todayAttendanceStatus = '';
    _isLoading = false;
    _historyList = [];
    _isLoadingHistory = false;
    _isFetchingMoreHistory = false;
    _historyCurrentPage = 1;
    _historyTotalPages = 1;
    _historyTotalContent = 0;
    _historyDateFilter = null;
    notifyListeners();
  }
}
