import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class SubjectServices {
  // Get subjects
  Future<Response> getAllSubjects({required int pageNo}) async {
    final response = await ApiServices.get('${ApiEndpoints.subjects}?page=$pageNo');
    return response;
  }
}