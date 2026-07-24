import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class TermExamServices {
  // fetch marks added by teacher
  Future<Response> fetchTermExamMarksAddedByTeacher({required int pageNo}) async {
    final teacherId = await AuthStorageService().getUserId();
    final response = await ApiServices.get(
      "${ApiEndpoints.marksAddedByTeacher}?recorded_by=$teacherId&limit=${AppConstants.paginationLimit}&page=$pageNo",
    );
    return response;
  }

  // fetch single marks
  Future<Response> fetchSingleTermExamMarks({required int marksId}) async {
    final response = await ApiServices.get("${ApiEndpoints.marks}/$marksId");
    return response;
  }

  // add student marks
  Future<Response> addStudentTermExamMarks({
    required int classId,
    required String title,
    required String date,
    required int subjectId,
    required int totalMarks,
    required String term,
    required List<Map<String, dynamic>> studentMarks,
  }) async {
    final teacherId = await AuthStorageService().getUserId();
    final response = await ApiServices.post(ApiEndpoints.marks, {
      "class_id": classId,
      "subject_id": subjectId,
      "internal_name": title,
      "max_marks": totalMarks,
      "date": date,
      "recorded_by": teacherId,
      "marks": studentMarks,
      "term":term,
    });
    return response;
  }

  // edit mark details
  Future<Response> editTermExamMarksDetails({
    required String title,
    required String date,
    required int subjectId,
    required double totalMarks,
    required int marksId,
  }) async {
    final response = await ApiServices.put("${ApiEndpoints.marks}/$marksId", {
      "subject_id": subjectId,
      "internal_name": title,
      "max_marks": totalMarks,
      "date": date,
    });
    return response;
  }

  // edit student marks
  Future<Response> editStudentTermExamMarks({
    required int marksId,
    required List<Map<String, dynamic>> editedMarks,
  }) async {
    final response = await ApiServices.put(ApiEndpoints.marksBulkUpdate, {
      "internal_id": marksId,
      "marks": editedMarks,
    });
    return response;
  }

  // fetch student marks
  Future<Response> fetchStudentTermExamMarks({
    required int pageNo,
    required int studentId,
    required bool forStaff,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? "${ApiEndpoints.studentMarks}/$studentId?page=$pageNo&limit=${AppConstants.paginationLimit}"
          : "${ApiEndpoints.studentMarksForParent}/$studentId?page=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }
}
