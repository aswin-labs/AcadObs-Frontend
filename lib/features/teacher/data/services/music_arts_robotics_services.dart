import 'dart:developer';

import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class MusicArtsRoboticsServices {
  // Get Co-Scholastic Music or Arts or Robotics areas by Year/Standard
  // Endpoint: /teacher/getCoScholasticMusicOrArtsOrRobticsByYear/:year
  Future<Response> getCoScholasticMusicOrArtsOrRobticsByYear(
    dynamic year,
  ) async {
    final endpoint =
        "${ApiEndpoints.getCoScholasticMusicOrArtsOrRobticsByYear}/$year";
    log(
      "GET $endpoint",
      name: "MUSIC_ARTS_ROBOTICS_SERVICES",
    );

    try {
      final response = await ApiServices.get(endpoint);
      log(
        "Response (${response.statusCode}): ${response.data}",
        name: "MUSIC_ARTS_ROBOTICS_SERVICES",
      );
      return response;
    } catch (e, stack) {
      log(
        "Error in getCoScholasticMusicOrArtsOrRobticsByYear: $e",
        name: "MUSIC_ARTS_ROBOTICS_SERVICES",
        stackTrace: stack,
      );
      rethrow;
    }
  }

  // Create Student Music or Arts or Robotics Assessment
  // Endpoint: /teacher/createStudentMusicOrArtsOrRoboticsAssessment
  // Payload:
  // {
  //   "exam_id": 2,
  //   "area_id": 3,
  //   "assessed_at": "2026-10-13",
  //   "assessments": [
  //     {
  //       "student_id": 101,
  //       "grade": "A"
  //     }
  //   ]
  // }
  Future<Response> createStudentMusicOrArtsOrRoboticsAssessment({
    required Map<String, dynamic> payload,
  }) async {
    final endpoint = ApiEndpoints.createStudentMusicOrArtsOrRoboticsAssessment;
    log(
      "POST $endpoint\nPayload: $payload",
      name: "MUSIC_ARTS_ROBOTICS_SERVICES",
    );

    try {
      final response = await ApiServices.post(endpoint, payload);
      log(
        "Response (${response.statusCode}): ${response.data}",
        name: "MUSIC_ARTS_ROBOTICS_SERVICES",
      );
      return response;
    } catch (e, stack) {
      log(
        "Error in createStudentMusicOrArtsOrRoboticsAssessment: $e",
        name: "MUSIC_ARTS_ROBOTICS_SERVICES",
        stackTrace: stack,
      );
      rethrow;
    }
  }

  // Get Recorded Co-Scholastic Assessments by Me
  // Endpoint: /teacher/getCoScholasticAssessmentRecordedByMe
  Future<Response> getCoScholasticAssessmentRecordedByMe({
    int page = 1,
    int limit = 15,
    String? searchQuery,
    int? examId,
    int? classId,
    int? studentId,
  }) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      queryParams['q'] = searchQuery.trim();
    }
    if (examId != null) {
      queryParams['exam_id'] = examId;
    }
    if (classId != null) {
      queryParams['class_id'] = classId;
    }
    if (studentId != null) {
      queryParams['student_id'] = studentId;
    }

    final response = await ApiServices.get(
      ApiEndpoints.getCoScholasticAssessmentRecordedByMe,
      data: queryParams,
    );
    return response;
  }

  // Update Co-Scholastic Assessment by Assessment ID
  // Endpoint: /teacher/updateCoScholasticAssessmentById/:id
  Future<Response> updateCoScholasticAssessmentById({
    required int assessmentId,
    required Map<String, dynamic> payload,
  }) async {
    final endpoint =
        "${ApiEndpoints.updateCoScholasticAssessmentById}/$assessmentId";
    log(
      "PUT $endpoint\nPayload: $payload",
      name: "MUSIC_ARTS_ROBOTICS_SERVICES",
    );

    try {
      final response = await ApiServices.put(
        endpoint,
        payload,
      );
      log(
        "Response (${response.statusCode}): ${response.data}",
        name: "MUSIC_ARTS_ROBOTICS_SERVICES",
      );
      return response;
    } on DioException catch (dioErr) {
      log(
        "DioException (${dioErr.response?.statusCode}): ${dioErr.response?.data} | Message: ${dioErr.message}",
        name: "MUSIC_ARTS_ROBOTICS_SERVICES",
      );
      rethrow;
    } catch (e, stack) {
      log(
        "Error in updateCoScholasticAssessmentById: $e",
        name: "MUSIC_ARTS_ROBOTICS_SERVICES",
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
