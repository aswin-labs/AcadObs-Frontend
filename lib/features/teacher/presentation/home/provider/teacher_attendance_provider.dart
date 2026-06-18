import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
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


  // get today attendance status
  Future<void> getTodayAttendanceStatus() async {
    _isLoading = true;
    _todayAttendanceStatus = '';
    notifyListeners();

    try {
      final response =
          await TeacherAttendanceServices().getTodayAttendanceStatus();

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

  // Check in attendance
  Future<void> checkInAttendance({
    required BuildContext context,
    required String latitude,
    required String longitude,
  }) async {
    _isLoadingForChangeStatus = true;

    PopupLoader.show(context, message: "Updating status...");

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
      if (context.mounted) {
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
  }) async {
    _isLoadingForChangeStatus = true;

    PopupLoader.show(context, message: "Updating status...");

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

      log("Error checking out attendance: $e");
    } finally {
      if (context.mounted) {
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
    notifyListeners();
  }
}
