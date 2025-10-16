import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/file_picker_provider.dart';

class StudentLeaveRequestServices {
  final int schoolId = StorageServices.getSchoolId;
  // create leave request
  Future<Response> createStudentLeaveRequest({
    required BuildContext context,
    required String fromDate,
    required String toDate,
    required String leaveType,
    required String reason,
    required int studentId,
    String? leaveDuration,
    ProgressCallback? onSendProgress,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile('attachment');
    final fileUploadPath = fileUpload?.path;

    final formData = FormData.fromMap({
      "school_id": schoolId,
      // "user_id": userId,
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
      ApiEndpoints.createStudentLeaveRequest,
      formData,
      isFormData: true,
      onSendProgress: onSendProgress,
    );
    log(response.toString());
    return response;
  }

  // Get student leave requests
  Future<Response> fetchAllStudentLeaveRequests({
    required int pageNo,
    required int studentId,
    required bool forParent,
  }) async {
    final url = await ApiServices.get(
      forParent
          ? "${ApiEndpoints.getStudentLeaveRequest}/$studentId&pageNo=$pageNo&limit=${AppConstants.paginationLimit}"
          : "${ApiEndpoints.studentLeaveRequestStaff}/$studentId&pageNo=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return url;
  }

  //get student leave request for the class teacher
  Future<Response> getStudentLeaveRequestsForClassTeacher() async {
    final response = await ApiServices.get(ApiEndpoints.studentLeaveLetter);
    return response;
  }

  //notification
  Future<Response> getLeaveRequestNotification() async {
    final response = await ApiServices.get(
      ApiEndpoints.leaveRequestNotification,
    );
    return response;
  }
}
