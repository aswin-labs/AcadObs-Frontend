import 'dart:developer';

import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class PhysicalCoscholasticServices {
  // Create Student Physical Assessment
  // Endpoint: /teacher/createStudentPhysicalAssessment
  Future<Response> createStudentPhysicalAssessment({
    required Map<String, dynamic> payload,
  }) async {
    final response = await ApiServices.post(
      ApiEndpoints.createStudentPhysicalAssessment,
      payload,
    );
    return response;
  }

  // Get Co-Scholastic Assessments Recorded by Me
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

  // Update Co-Scholastic Assessment By Id
  // Endpoint: /teacher/updateCoScholasticAssessmentById/:id
  Future<Response> updateCoScholasticAssessmentById({
    required int assessmentId,
    required Map<String, dynamic> payload,
  }) async {
    final endpoint =
        "${ApiEndpoints.updateCoScholasticAssessmentById}/$assessmentId";
    log(
      "PUT $endpoint\nPayload: $payload",
      name: "CO_SCHOLASTIC_SERVICES",
    );

    try {
      final response = await ApiServices.put(
        endpoint,
        payload,
      );
      log(
        "Response (${response.statusCode}): ${response.data}",
        name: "CO_SCHOLASTIC_SERVICES",
      );
      return response;
    } on DioException catch (dioErr) {
      log(
        "DioException (${dioErr.response?.statusCode}): ${dioErr.response?.data} | Message: ${dioErr.message}",
        name: "CO_SCHOLASTIC_SERVICES",
      );
      rethrow;
    } catch (e, stack) {
      log(
        "Error in updateCoScholasticAssessmentById: $e",
        name: "CO_SCHOLASTIC_SERVICES",
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
