import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
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

  // Logout
  Future<Response> logout({required String refreshToken}) async {
    final response = await ApiServices.post(ApiEndpoints.logout, {
      "refreshToken": refreshToken,
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

  Future<Response> fetchSchoolDetailsForGuardianBySchoolId({
    required int schoolId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.schoolDetailsForGuardianBySchoolId}/$schoolId",
    );
    return response;
  }

  // send fcm token safely
  Future<Response?> sendFcmToken() async {
    try {
      String? token;
      try {
        token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        // Firebase token fetching may fail if notification permission is denied
      }

      token ??= await AuthStorageService().getFcmToken();

      if (token == null || token.isEmpty) {
        return null;
      }

      final response = await ApiServices.put(ApiEndpoints.guardianNotification, {
        "fcm_token": token,
      });
      return response;
    } catch (e) {
      return null;
    }
  }

  // get user permissions
  Future<Response> getStaffPermissions() async {
    final response = await ApiServices.get(ApiEndpoints.staffPermissions);
    return response;
  }
}
