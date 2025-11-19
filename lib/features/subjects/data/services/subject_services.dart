import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class SubjectServices {
  // Fetch subjects
  Future<Response> fetchAllSubjects() async {
    final response = await ApiServices.get(ApiEndpoints.subjectsAll);
    return response;
  }
}
