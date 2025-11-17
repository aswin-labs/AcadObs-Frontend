import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/teacher/data/services/teacher_attendance_services.dart';
import 'package:flutter/material.dart';

class TeacherAttendanceProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingForChangeStatus = false;
  bool get isLoadingForChangeStatus => _isLoadingForChangeStatus;

  String _todayAttendanceStatus = '';
  String get todayAttendanceStatus => _todayAttendanceStatus;

  bool _isFetchedOnce = false;

  // get today attendance status
  Future<void> getTodayAttendanceStatus() async {
    if (_isFetchedOnce) return;
    _isLoading = true;
    _todayAttendanceStatus = '';
    notifyListeners();
    try {
      final response =
          await TeacherAttendanceServices().getTodayAttendanceStatus();
      if (response.statusCode == 200) {
        _todayAttendanceStatus = response.data['status'];
        _isFetchedOnce = true;
      }
    } catch (e) {
      log(e.toString());
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
    _isFetchedOnce = false;
    _isLoadingForChangeStatus = true;
    PopupLoader.show(context, message: "Updating status...");
    notifyListeners();
    try {
      // if (position != null) {
      final response = await TeacherAttendanceServices().checkInAttendance(
        latitude: latitude,
        longitude: longitude,
      );
      if (response.statusCode == 201) {
        await getTodayAttendanceStatus();
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: response.data['message'],
          type: SnackbarType.success,
        );
        if (!context.mounted) return;
        PopupLoader.hide(context);
      } else if (response.statusCode == 400) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: response.data['message'],
          type: SnackbarType.failure,
        );
        if (!context.mounted) return;
        PopupLoader.hide(context);
      } else {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Unknown Error!",
          type: SnackbarType.failure,
        );
        if (!context.mounted) return;
        PopupLoader.hide(context);
        // }
      }
    } catch (e) {
      log("Error sending location: $e");
    } finally {
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
    _isFetchedOnce = false;
    _isLoadingForChangeStatus = true;
    PopupLoader.show(context, message: "Updating status...");
    notifyListeners();
    try {
      final response = await TeacherAttendanceServices().checkOutAttendance(
        latitude: latitude,
        longitude: longitude,
      );
      if (response.statusCode == 200) {
        await getTodayAttendanceStatus();
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: response.data['message'],
          type: SnackbarType.success,
        );
        if (!context.mounted) return;
        PopupLoader.hide(context);
      } else if (response.statusCode == 400) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: response.data['message'],
          type: SnackbarType.failure,
        );
        if (!context.mounted) return;
        PopupLoader.hide(context);
      } else {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Unknown Error!",
          type: SnackbarType.failure,
        );
        if (!context.mounted) return;
        PopupLoader.hide(context);
      }
    } catch (e) {
      log("Error sending location: $e");
    } finally {
      _isLoadingForChangeStatus = false;
      notifyListeners();
    }
  }
}
