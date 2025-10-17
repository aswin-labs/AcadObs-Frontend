import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/file_picker_provider.dart';

class TeacherLeaveRequestServices {
  // create leave request
  Future<Response> createLeaveRequest({
    required BuildContext context,
    required String fromDate,
    required String toDate,
    required String leaveType,
    required String reason,
    required String leaveDuration,
    String? halfSection,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile('attachment');
    final fileUploadPath = fileUpload?.path;
    final formData = {
      "from_date": fromDate,
      "to_date": toDate,
      "leave_type": leaveType.toLowerCase(),
      "reason": reason,
      "leave_duration": leaveDuration,
      if (leaveDuration == 'half') "half_section": halfSection,
      if (fileUploadPath != null)
        "attachment": await MultipartFile.fromFile(
          fileUploadPath,
          filename: fileUploadPath.split('/').last,
        ),
    };
    final response = await ApiServices.post(
      ApiEndpoints.staffLeaveRequest,
      formData,
      isFormData: true,
    );
    return response;
  }

  // Get teacher leave requests
  Future<Response> fetchAllLeaveRequests({required int pageNo}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.staffLeaveRequest}?page=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }

  // student leave request permission
  Future<Response> studentLeavePermission({
    required int leaveRequestId,
    required String status,
  }) async {
    final response = await ApiServices.patch(
      "${ApiEndpoints.studentLeavePermission}/$leaveRequestId?status=$status",
    );
    return response;
  }
}
