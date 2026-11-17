import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:dio/dio.dart';

class AiInsightsServices {
  Future<Response> fetchStudentAiSkills({required int studentId}) async {
    final url = '${BaseUrls.aiApi}${ApiEndpoints.aiStudentSkills(studentId)}';
    final response = await ApiServices.get(url);
    return response;
  }

  Future<Response> fetchStudentCareerPath({required int studentId}) async {
    final url =
        '${BaseUrls.aiApi}${ApiEndpoints.aiStudentCareerPath(studentId)}';
    final response = await ApiServices.get(url);
    return response;
  }
}
