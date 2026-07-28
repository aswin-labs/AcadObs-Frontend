import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/api_services.dart';

class MyClassServices {
  // Fetch my class marks
  Future<Response> fetchMyClassMarks({required int pageNo}) async {
    final response = await ApiServices.get(ApiEndpoints.getMyClassMarks);
    return response;
  }

  // Fetch my class internal marks
  Future<Response> fetchMyClassInternalMarks({required int pageNo}) async {
    final response = await ApiServices.get(
      ApiEndpoints.getMyClassInternalMarks,
    );
    return response;
  }
}
