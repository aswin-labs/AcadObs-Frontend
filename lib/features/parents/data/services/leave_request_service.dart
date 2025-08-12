import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/file_picker_provider.dart';

class StudentLeaveRequestServices {
  final int schoolId = 1;
  final int userId = 6;
  final int studentId = 2;
  // create leave request
  Future<Response> createStudentLeaveRequest({
    required BuildContext context,
    required String fromDate,
    required String toDate,
    required String leaveType,
    required String reason,
    String? leaveDuration,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile('attachment');
    final fileUploadPath = fileUpload?.path;

    final formData = FormData.fromMap({
      "school_id": schoolId,
      "user_id": userId,
      "from_date": fromDate,
      "to_date": toDate,
      "leave_type": leaveType.toLowerCase(),
      "reason": reason,
      "student_id": studentId,
      if (fileUploadPath != null)
        "attachment": await MultipartFile.fromFile(
          fileUploadPath,
          filename: fileUploadPath.split('/').last,
        ),
    });
    final response = await ApiServices.post(
      ApiEndpoints.studentLeaveRequest,
      formData,
      isFormData: true,
    );
    log(response.toString());
    return response;
  }

  // Get student leave requests
  Future<Response> fetchAllStudentLeaveRequests({required int pageNo}) async {
    final url = await ApiServices.get(
      "${ApiEndpoints.studentLeaveRequest}?user_id=$userId&student_id=$studentId&school_id=$schoolId&$pageNo&limit=${AppConstants.paginationLimit}",
    );
    log("Fetching leave requests from: $url");
    // final response = await ApiServices.get(url.toString());
    return url;
  }
}
