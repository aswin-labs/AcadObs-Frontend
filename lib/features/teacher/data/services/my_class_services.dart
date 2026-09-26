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

  // Fetch Competency and Indicators
  Future<Response> fetchCompetencyAndIndicators() async {
    final response = await ApiServices.get(
      ApiEndpoints.getCompetencyAndIndicators,
    );
    return response;
  }

  // Create Student Competency Assessment
  Future<Response> createStudentCompetencyAssessment({
    required int studentId,
    required int examId,
    required List<Map<String, dynamic>> assessments,
  }) async {
    final response = await ApiServices.post(
      ApiEndpoints.createStudentCompetencyAssessment,
      {
        'student_id': studentId,
        'exam_id': examId,
        'assessments': assessments,
      },
    );
    return response;
  }

  // Get Competency Assessment by Student ID and Exam ID
  Future<Response> getCompetencyAssessmentByStudentIdAndExamId({
    required int studentId,
    required int examId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getCompetencyAssessmentByStudentIdAndExamId}/$studentId/$examId",
    );
    return response;
  }

  // Bulk Update Competency Assessment
  Future<Response> bulkUpdateCompetencyAssessment({
    required int studentId,
    required int examId,
    required List<Map<String, dynamic>> assessments,
  }) async {
    final response = await ApiServices.put(
      ApiEndpoints.bulkUpdateCompetencyAssessment,
      {
        'student_id': studentId,
        'exam_id': examId,
        'assessments': assessments,
      },
    );
    return response;
  }

  // Delete Competency Assessment
  Future<Response> deleteCompetencyAssessment({
    required int studentId,
    required int examId,
  }) async {
    final response = await ApiServices.delete(
      "${ApiEndpoints.deleteCompetencyAssessment}/$studentId/$examId",
    );
    return response;
  }

  // ==================== CO-SCHOLASTIC SERVICES ====================

  // Fetch Co-Scholastic Areas by Student ID
  Future<Response> fetchCoScholasticAreasByStudentId({
    required int studentId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getCoScholasticAreasListByStudentId}/$studentId",
    );
    return response;
  }

  // Create Student Co-Scholastic Assessment
  Future<Response> createStudentCoScholasticAssessment({
    required List<Map<String, dynamic>> assessments,
  }) async {
    final response = await ApiServices.post(
      ApiEndpoints.createStudentCoScholasticAssessment,
      assessments,
    );
    return response;
  }

  // Get Co-Scholastic Assessment by Student ID and Exam ID
  Future<Response> getCoScholasticAssessmentByStudentIdAndExamId({
    required int studentId,
    required int examId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getCoScholasticAssessmentByStudentIdAndExamId}/$studentId/$examId",
    );
    return response;
  }

  // Bulk Update Co-Scholastic Assessment
  Future<Response> bulkUpdateCoScholasticAssessment({
    required int studentId,
    required int examId,
    required List<Map<String, dynamic>> assessments,
  }) async {
    final response = await ApiServices.put(
      ApiEndpoints.bulkUpdateCoScholasticAssessment,
      assessments,
    );
    return response;
  }

  // Delete Co-Scholastic Assessment
  Future<Response> deleteCoScholasticAssessment({
    required int studentId,
    required int examId,
  }) async {
    final response = await ApiServices.delete(
      "${ApiEndpoints.deleteCoScholasticAssessment}/$studentId/$examId",
    );
    return response;
  }
}

