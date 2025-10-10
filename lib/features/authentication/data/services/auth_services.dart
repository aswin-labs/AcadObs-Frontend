import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class AuthServices {
  // Login
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiServices.post(ApiEndpoints.login, {
      "email": email,
      "password": password,
    });
    return response;
  }

  // get schools by parent
  Future<Response> fetchSchoolsByParent() async {
    final response = await ApiServices.get(ApiEndpoints.schoolsByGuardian);
    return response;
  }

  // fetch school details for teacher
  Future<Response> fetchSchoolDetailsForTeacher() async {
    final response = await ApiServices.get(
      ApiEndpoints.schoolDetailsForTeacher,
    );
    return response;
  }
}
