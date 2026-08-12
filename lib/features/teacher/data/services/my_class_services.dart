import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/api_services.dart';

class MyClassServices {
  // Fetch my class marks
  Future<Response> fetchMyClassMarks({required int pageNo}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getMyClassMarks}?page=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }

  // Fetch my class internal marks
  Future<Response> fetchMyClassInternalMarks({required int pageNo}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getMyClassInternalMarks}??page=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }

  // fetch my class homeworks
  Future<Response> fetchMyClassHomeworks({required int pageNo}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getMyClassHomeworks}?page=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }

  // Get class-wise term marks PDF bytes
  Future<Response> getClassWiseTermMarksPdf({
    required int examId,
    required String internalName,
    required int classId,
  }) async {
    final response = await ApiServices.dio.get(
      ApiEndpoints.getClassWaiseTermMarksPdf,
      queryParameters: {
        'exam_id': examId,
        'internal_name': internalName,
        'class_id': classId,
      },
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    return response;
  }
}
