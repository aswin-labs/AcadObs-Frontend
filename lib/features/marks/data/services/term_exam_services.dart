import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class TermExamServices {
  // fetch term exams
  Future<Response> fetchTermExams() async {
    final response = await ApiServices.get(ApiEndpoints.termExams);
    return response;
  }

  // fetch marks added by teacher
  Future<Response> fetchTermExamMarksAddedByTeacher({
    required int pageNo,
    int? subjectId,
    int? classId,
    int? examId,
    String? query,
  }) async {
    final teacherId = await AuthStorageService().getUserId();
    final searchQuery = query != null ? Uri.encodeComponent(query) : '';
    String url =
        "${ApiEndpoints.termExamAddedByTeacher}?recorded_by=$teacherId&limit=${AppConstants.paginationLimit}&page=$pageNo&q=$searchQuery";
    if (subjectId != null) {
      url += "&subject_id=$subjectId";
    }
    if (classId != null) {
      url += "&class_id=$classId";
    }
    if (examId != null) {
      url += "&exam_id=$examId";
    }
    final response = await ApiServices.get(url);
    return response;
  }

  // add student marks
  Future<Response> addStudentTermExamMarks({
    required int classId,
    required String title,
    required String date,
    required int subjectId,
    required int totalMarks,
    required int termExamId,
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
      "exam_id": termExamId,
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
          ? "${ApiEndpoints.studentTermExamMarksForTeacher}/$studentId?page=$pageNo&limit=${AppConstants.paginationLimit}"
          : "${ApiEndpoints.studentTermExamMarksForGuardian}/$studentId?page=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }

  // delete marks
  Future<Response> deleteTermExamMarks({required int marksId}) async {
    final response = await ApiServices.delete("${ApiEndpoints.marks}/$marksId");
    return response;
  }

  // fetch all multi teacher subject marks
  Future<Response> fetchMultiTeacherSubjectMarks({
    required int pageNo,
    int? examId,
    int? classId,
    int? subjectId,
    String? searchQuery,
  }) async {
    final queryParams = <String>[
      'page=$pageNo',
      'limit=${AppConstants.paginationLimit}',
    ];
    if (searchQuery != null && searchQuery.isNotEmpty) {
      queryParams.add('q=${Uri.encodeComponent(searchQuery)}');
    }
    if (subjectId != null) {
      queryParams.add('subject_id=$subjectId');
    }
    if (classId != null) {
      queryParams.add('class_id=$classId');
    }
    if (examId != null) {
      queryParams.add('exam_id=$examId');
    }
    final response = await ApiServices.get(
      "${ApiEndpoints.myMultiTeacherSubjectInternalMarks}?${queryParams.join('&')}",
    );
    return response;
  }

  // fetch single mark for Multi teacher subject
  Future<Response> fetchSingleMultiTeacherSubjectMarks({
    required int marksId,
    required int subjectId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.getInternalMarksByIdWithSubject}/$marksId?subject_id=$subjectId",
    );
    return response;
  }

  // check mark already exists
  Future<Response> checkExistingTermMarks({
    required int classId,
    required String title,
    required String date,
    required int subjectId,
    required int termExamId,
  }) async {
    final teacherId = await AuthStorageService().getUserId();
    final response =
        await ApiServices.post(ApiEndpoints.checkExistingInternal, {
          "class_id": classId,
          "subject_id": subjectId,
          "internal_name": title,
          "date": date,
          "recorded_by": teacherId,
          "exam_id": termExamId,
        });
    return response;
  }
}
