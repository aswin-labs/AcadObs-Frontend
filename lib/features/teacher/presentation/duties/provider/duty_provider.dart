import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/teacher/data/models/staff_duty_model.dart';
import 'package:acadobs/features/teacher/data/models/updated_duty_response_model.dart';
import 'package:acadobs/features/teacher/data/services/duty_services.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DutyProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  final List<GroupedDuty> _staffDuties = [];
  List<GroupedDuty> get staffDuties => _staffDuties;

  UpdatedDutyResponse? updatedDutyResponse;

  Duty? singleDuty;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

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
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List dutiesJson = data['duties'];

        final List<GroupedDuty> fetchedDuties =
            dutiesJson
                .map((jsonItem) => GroupedDuty.fromJson(jsonItem))
                .toList();

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
      final file = context.read<FilePickerProvider>().getFile('solved_file');
      final isFilePicked = file?.path?.isNotEmpty ?? false;
      final hasRemarks = (remarks != null && remarks.trim().isNotEmpty);
      final response = await DutyServices().addDutyRemarksAndFile(
        context: context,
        dutyId: dutyId,
        remarks: remarks ?? "",
      );

      if (response.statusCode == 200) {
        updatedDutyResponse = UpdatedDutyResponse.fromJson(
          response.data['updatedDuty'],
        );
        await fetchStaffDuties(forceRefresh: true);

        if (!context.mounted) return;
        PopupLoader.hide(context);

        // ✅ Show custom message depending on what's submitted
        String successMessage;
        if (hasRemarks && isFilePicked) {
          successMessage = "Remarks and file uploaded successfully";
        } else if (hasRemarks) {
          successMessage = "Remarks added successfully";
        } else if (isFilePicked) {
          successMessage = "File uploaded successfully";
        } else {
          successMessage = "Updated successfully";
        }

        CustomSnackbar.show(
          context,
          message: successMessage,
          type: SnackbarType.success,
          bottomPadding: 5,
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

  //get single duty
  Future<void> fetchSingleDuties({required int dutyId}) async {
    _isLoading = true;
    try {
      final response = await DutyServices().fetchSingleDuties(dutyId: dutyId);
      if (response.statusCode == 200) {
        final data = response.data;
        singleDuty = Duty.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
