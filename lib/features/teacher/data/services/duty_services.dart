import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DutyServices {
  // Fetch Staff Duties
  Future<Response> fetchStaffDuties({required int pageNo}) async {
    final teacherId = await AuthStorageService().getUserId();

    final response = await ApiServices.get(
      '${ApiEndpoints.staffDuties}?page=$pageNo&limit=${AppConstants.paginationLimit}&staff_id=$teacherId',
    );
    return response;
  }

  // Update Duty status
  Future<Response> updateDutyStatus({
    required int dutyId,
    required String status,
  }) async {
    final teacherId = await AuthStorageService().getUserId();

    final formData = {"staff_id": teacherId, "status": status};
    final response = await ApiServices.put(
      '${ApiEndpoints.updateDutyStatus}/$dutyId',
      formData,
      isFormData: true,
    );
    return response;
  }

  // Add duty renarks and file
  Future<Response> addDutyRemarksAndFile({
    required BuildContext context,
    required int dutyId,
    required String remarks,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(
      'solved_file',
    );
    final teacherId = await AuthStorageService().getUserId();

    final fileUploadPath = fileUpload?.path;
    final formData = {
      "staff_id": teacherId,
      if (remarks.trim().isNotEmpty) "remarks": remarks,
      if (fileUploadPath != null)
        "solved_file": await MultipartFile.fromFile(
          fileUploadPath,
          filename: fileUploadPath.split('/').last,
        ),
    };

    final response = await ApiServices.put(
      '${ApiEndpoints.updateDutyStatus}/$dutyId',
      formData,
      isFormData: true,
    );
    return response;
  }
}
