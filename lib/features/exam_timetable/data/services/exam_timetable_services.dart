import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class ExamTimetableServices {
  /// Fetch exam titles (e.g. ["PT", "Term", "Internal", "Model"])
  Future<Response> fetchExamTitles({bool forGuardian = false}) async {
    if (forGuardian) {
      try {
        return await ApiServices.get(ApiEndpoints.guardianGetExamTitles);
      } catch (_) {
        return await ApiServices.get(ApiEndpoints.teacherGetExamTitles);
      }
    }
    final response = await ApiServices.get(ApiEndpoints.teacherGetExamTitles);
    return response;
  }

  /// Fetch all exams (terms) for guardian with fallback to teacher endpoint
  Future<Response> fetchAllExamsForGuardian() async {
    try {
      return await ApiServices.get(ApiEndpoints.guardianGetAllExams);
    } catch (_) {
      return await ApiServices.get(ApiEndpoints.allTermExams);
    }
  }

  /// Fetch exam timetable for a standard, title, and exam_id without pagination
  Future<Response> fetchExamTimetableByStandard({
    required int standard,
    required String title,
    required int examId,
    int limit = 100,
  }) async {
    final encodedTitle = Uri.encodeComponent(title);
    final url =
        "${ApiEndpoints.teacherGetExamTimetableByStandard}?standard=$standard&title=$encodedTitle&exam_id=$examId&limit=$limit";
    final response = await ApiServices.get(url);
    return response;
  }

  /// Fetch exam timetable for teacher's own subjects by exam_id and title
  Future<Response> fetchExamTimetableByOwnSubjects({
    required int examId,
    required String title,
    int limit = 100,
  }) async {
    final encodedTitle = Uri.encodeComponent(title);
    final url =
        "${ApiEndpoints.teacherGetExamTimetableByOwnSubjects}?exam_id=$examId&title=$encodedTitle&limit=$limit";
    final response = await ApiServices.get(url);
    return response;
  }

  /// Fetch exam timetable for a student (guardian view) by studentId, exam_id, and title
  Future<Response> fetchExamTimetableByStudentId({
    required int studentId,
    required int examId,
    required String title,
    int limit = 100,
  }) async {
    final encodedTitle = Uri.encodeComponent(title);
    final url =
        "${ApiEndpoints.guardianGetExamTimetableByStudentId}/$studentId?exam_id=$examId&title=$encodedTitle&limit=$limit";
    final response = await ApiServices.get(url);
    return response;
  }
}
