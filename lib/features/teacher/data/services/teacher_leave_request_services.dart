import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/file_picker_provider.dart';

class TeacherLeaveRequestServices {
  final int schoolId = 1;
  final int userId = 3;
  // create leave request
  Future<Response> createLeaveRequest({
    required BuildContext context,
    required String fromDate,
    required String toDate,
    required String leaveType,
    required String reason,
    String? leaveDuration,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile('attachment');
    final fileUploadPath = fileUpload?.path;
    final formData = {
      "school_id": schoolId,
      "user_id": userId,
      "from_date": fromDate,
      "to_date": toDate,
      "leave_type": leaveType.toLowerCase(),
      "reason": reason,
      "leave_duration": leaveDuration,
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
      "${ApiEndpoints.staffLeaveRequest}?user_id=$userId&page=$pageNo&limit=10",
    );
    return response;
  }
}
