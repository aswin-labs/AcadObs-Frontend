import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:acadobs/features/teacher/data/services/teacher_leave_request_services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherLeaveRequestProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  final List<LeaveModel> _leaveRequests = [];
  List<LeaveModel> get leaveRequests => _leaveRequests;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  // Fetch Staff Duties
  Future<void> fetchAllLeaveRequests({
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
        _leaveRequests.clear();
        _isFetchedOnce = false;
      }
      final response = await TeacherLeaveRequestServices()
          .fetchAllLeaveRequests(pageNo: _currentPage);
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List leavesJson = data['leaves'];

        final List<LeaveModel> fetchedLeaves =
            leavesJson
                .map((jsonItem) => LeaveModel.fromJson(jsonItem))
                .toList();
        fetchedLeaves.sort((a, b) {
          return b.createdAt!.compareTo(a.createdAt!);
        });
        _leaveRequests.addAll(fetchedLeaves);
        _isFetchedOnce = true;
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
  Future<void> createLeaveRequest({
    required BuildContext context,
    required String fromDate,
    required String toDate,
    required String leaveType,
    required String reason,
    required String leaveDuration,
    String? halfSection,
  }) async {
    _isLoadingTwo = true;
    PopupLoader.show(context, message: "Sending Leave Request...");
    notifyListeners();
    try {
      final response = await TeacherLeaveRequestServices().createLeaveRequest(
        context: context,
        fromDate: fromDate,
        toDate: toDate,
        leaveType: leaveType,
        reason: reason,
        leaveDuration: leaveDuration,
        halfSection: halfSection,
      );
      if (response.statusCode == 201) {
        await fetchAllLeaveRequests(forceRefresh: true);
        if (!context.mounted) return;
        PopupLoader.hide(context);
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Leave Request Submitted Successfully",
          type: SnackbarType.success,
        );
      } else {
        if (!context.mounted) return;
        PopupLoader.hide(context);
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: response.data["error"],
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log(e.toString());
      notifyListeners();
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // student leave permission
  Future<void> studentLeavePermission({
    required BuildContext context,
    required int leaveRequestId,
    required String status,
  }) async {
    _isLoadingTwo = true;
    PopupLoader.show(context, message: "Changing Leave Status...");
    notifyListeners();
    try {
      final response = await TeacherLeaveRequestServices()
          .studentLeavePermission(
            leaveRequestId: leaveRequestId,
            status: status,
          );
      if (response.statusCode == 200) {
        if (!context.mounted) return;
        PopupLoader.hide(context);
        context
            .read<StudentLeaveRequestProvider>()
            .getStudentLeaveRequestsForClassTeacher(forceRefresh: true);
        CustomSnackbar.show(
          context,
          message: "Status Changed Successfully",
          type: SnackbarType.info,
        );
        Navigator.pop(context);
      } else {
        if (!context.mounted) return;
        PopupLoader.hide(context);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }
}
