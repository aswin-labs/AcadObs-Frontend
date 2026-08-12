import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class MarksServices {
  // fetch marks added by teacher
  Future<Response> fetchMarksAddedByTeacher({required int pageNo}) async {
    final teacherId = await AuthStorageService().getUserId();
    final response = await ApiServices.get(
      "${ApiEndpoints.marksAddedByTeacher}?recorded_by=$teacherId&limit=${AppConstants.paginationLimit}&page=$pageNo",
    );
    return response;
  }

  // fetch single marks
  Future<Response> fetchSingleMarks({required int marksId}) async {
    final response = await ApiServices.get("${ApiEndpoints.marks}/$marksId");
    return response;
  }

  // add student marks
  Future<Response> addStudentMarks({
    required int classId,
    required String title,
    required String date,
    required int subjectId,
    required int totalMarks,
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
    });
    return response;
  }

  // edit mark details
  // edit mark details
  Future<Response> editMarksDetails({
    String? title,
    String? date,
    int? subjectId,
    double? totalMarks,
    required int marksId,
  }) async {
    final Map<String, dynamic> data = {};

    if (subjectId != null) data["subject_id"] = subjectId;
    if (title != null) data["internal_name"] = title;
    if (totalMarks != null) data["max_marks"] = totalMarks;
    if (date != null) data["date"] = date;

    final response = await ApiServices.put(
      "${ApiEndpoints.marks}/$marksId",
      data,
    );

    return response;
  }

  // edit student marks
  Future<Response> editStudentMarks({
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
  Future<Response> fetchStudentMarks({
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

  // check mark already exists
  Future<Response> checkExistingInternalMarks({
    required int classId,
    required String title,
    required String date,
    required int subjectId,
  }) async {
    final teacherId = await AuthStorageService().getUserId();
    final response =
        await ApiServices.post(ApiEndpoints.checkExistingInternal, {
          "class_id": classId,
          "subject_id": subjectId,
          "internal_name": title,
          "date": date,
          "recorded_by": teacherId,
        });
    return response;
  }

  // fetch missing students
  Future<Response> fetchMissingStudents({
    required int classId,
    required List<int> studentIds,
  }) async {
    return await ApiServices.post(
      '${ApiEndpoints.getMissingStudentsListfromClassId}/$classId',
      {"studentIds": studentIds},
    );
  }

  // add missing student marks
  Future<Response> createNewMarksByInternalId({
    required int internalId,
    required List<Map<String, dynamic>> studentMarks,
  }) async {
    final response = await ApiServices.post(
      "${ApiEndpoints.createNewMarksByInternalId}/$internalId",
      studentMarks,
    );

    return response;
  }
}
