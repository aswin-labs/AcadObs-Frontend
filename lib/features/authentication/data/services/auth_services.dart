import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AuthServices {
  // Login
  Future<Response> login({
    required String identifier,
    required String password,
  }) async {
    final response = await ApiServices.post(ApiEndpoints.login, {
      "identifier": identifier,
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

  // send fcm token
  Future<Response> sendFcmToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    final response = await ApiServices.put(ApiEndpoints.guardianNotification, {
      "fcm_token": token,
    });
    return response;
  }

  // get user permissions
  Future<Response> getStaffPermissions() async {
    final response = await ApiServices.get(ApiEndpoints.staffPermissions);
    return response;
  }
}
