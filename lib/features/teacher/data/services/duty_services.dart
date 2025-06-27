import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api/api_end_points.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DutyServices {
  // Fetch Staff Duties
  Future<Response> fetchStaffDuties({
    required int pageNo,
    required int staffId,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.staffDuties}?page=$pageNo&staff_id=$staffId',
    );
    return response;
  }

  // Update Duty status
  Future<Response> updateDutyStatus({
    required int dutyId,
    required int staffId,
    required String status,
  }) async {
    final formData = {
      "staff_id":staffId,
      "status":status,
    };
    final response = await ApiServices.put(
      '${ApiEndpoints.updateDutyStatus}/$dutyId',
      formData,
      isFormData: true,
    );
    return response;
  }

  // Add duty renarks and file
  Future<Response> addDutyRemarksAndFile( 
    {
    required BuildContext context,
    required int dutyId,
    required int staffId,
    required String remarks,
  }) async {
    
    final fileUpload = context.read<FilePickerProvider>().getFile('solved_file');
    final fileUploadPath = fileUpload?.path;
    final formData = {
      "staff_id":staffId,
      "remarks":remarks,
      if (fileUploadPath != null)
        'solved_file': await MultipartFile.fromFile(fileUploadPath,
            filename: fileUploadPath.split('/').last),
    };
    final response = await ApiServices.put(
      '${ApiEndpoints.updateDutyStatus}/$dutyId',
      formData,
      isFormData: true,
    );
    return response;
  }
}
