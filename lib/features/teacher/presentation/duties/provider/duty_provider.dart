import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/teacher/data/models/staff_duty_model.dart';
import 'package:acadobs/features/teacher/data/models/updated_duty_response_model.dart';
import 'package:acadobs/features/teacher/data/services/duty_services.dart';
import 'package:flutter/material.dart';

class DutyProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  final List<StaffDuty> _staffDuties = [];
  List<StaffDuty> get staffDuties => _staffDuties;

  UpdatedDutyResponse? updatedDutyResponse;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  final staffId = 3; //Replace with the userId of staff

  // Fetch Staff Duties
  Future<void> fetchStaffDuties({
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
        _staffDuties.clear();
        _isFetchedOnce = false;
      }
      final response = await DutyServices().fetchStaffDuties(
        staffId: staffId,
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List dutiesJson = data['duties'];

        final List<StaffDuty> fetchedDuties =
            dutiesJson.map((jsonItem) => StaffDuty.fromJson(jsonItem)).toList();

        _staffDuties.addAll(fetchedDuties);
        _isFetchedOnce = true;
      } else {
        throw Exception('Failed to fetch staff duties: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear duty response
  void clearUpdatedDutyResponse() {
    updatedDutyResponse = null;
    notifyListeners();
  }

  // Update duty status - In Progress
  Future<void> updateDutyStatusInProgress({
    required BuildContext context,
    required int dutyId,
  }) async {
    _isLoadingTwo = true;
    PopupLoader.show(context, message: "Updating status...");
    notifyListeners();
    try {
      final response = await DutyServices().updateDutyStatus(
        dutyId: dutyId,
        staffId: staffId,
        status: "in_progress",
      );
      if (response.statusCode == 200) {
        updatedDutyResponse = UpdatedDutyResponse.fromJson(
          response.data['updatedDuty'],
        );
        await fetchStaffDuties(forceRefresh: true);
        if (!context.mounted) return;
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: "Duty status changed to In Progress",
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Update duty status - Completed
  Future<void> updateDutyStatusToCompleted({
    required BuildContext context,
    required int dutyId,
  }) async {
    _isLoadingTwo = true;
    PopupLoader.show(context, message: "Updating status...");
    notifyListeners();
    try {
      final response = await DutyServices().updateDutyStatus(
        dutyId: dutyId,
        staffId: staffId,
        status: "completed",
      );
      if (response.statusCode == 200) {
        updatedDutyResponse = UpdatedDutyResponse.fromJson(
          response.data['updatedDuty'],
        );
        await fetchStaffDuties(forceRefresh: true);
        if (!context.mounted) return;
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: "Duty status changed to Completed",
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Add remarks and file
  Future<void> addDutyRemarksAndFile({
    required BuildContext context,
    required int dutyId,
    String? remarks,
  }) async {
    _isLoadingTwo = true;
    PopupLoader.show(context, message: "Updating status...");
    notifyListeners();
    try {
      final response = await DutyServices().addDutyRemarksAndFile(
        context: context,
        dutyId: dutyId,
        staffId: staffId,
        remarks: remarks ?? "",
      );
      if (response.statusCode == 200) {
        updatedDutyResponse = UpdatedDutyResponse.fromJson(
          response.data['updatedDuty'],
        );
        await fetchStaffDuties(forceRefresh: true);
        if (!context.mounted) return;
        PopupLoader.hide(context);
        CustomSnackbar.show(
          context,
          message: "Added Remarks Successfully",
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
}
