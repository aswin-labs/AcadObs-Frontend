import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class AttendanceServices {
  final int _teacherId = 3; // to be changed
  // attendance by class and date
  Future<Response> fetchAttendanceByClassIdAndDate({
    required int classId,
    required String date,
    required int period,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.attendanceByClassIdAndDate}?class_id=$classId&date=$date&period=$period&teacher_id=$_teacherId',
    );
    return response;
  }

  // Submit attendance
  Future<Response> submitAttendance({
    required Map<String, dynamic> data,
  }) async {
    final response = await ApiServices.post(ApiEndpoints.attendance, data);
    return response;
  }

  // fetch attendance taken by teacher
  Future<Response> fetchAttendanceByTeacher({
    required String date,
    required int pageNo,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.attendanceByTeacher}?teacher_id=$_teacherId&page=$pageNo&limit=${AppConstants.paginationLimit}&date=$date',
    );
    return response;
  }

  // attendance by Id
  Future<Response> fetchAttendanceById({required int attendanceId}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.attendance}/$attendanceId",
    );
    return response;
  }

  // Edit attendance details
  Future<Response> editAttendanceDetails({
    required int attendanceId,
    required int period,
    required String date,
    required int subjectId,
  }) async {
    final response = await ApiServices.put(
      "${ApiEndpoints.attendance}/$attendanceId",
      {"period": period, "date": date, "subject_id": subjectId},
    );
    return response;
  }

  // Edit bulk attendance
  Future<Response> editBulkAttendance({
    required int attendanceId,
    required List<Map<String, dynamic>> attendanceList,
  }) async {
    final response = await ApiServices.put(
      "${ApiEndpoints.editBulkAttendance}/$attendanceId",
      {"data": attendanceList},
    );
    return response;
  }

  // Delete attendance
  Future<Response> deleteAttendance({required int attendanceId}) async {
    final response = await ApiServices.delete(
      "${ApiEndpoints.attendance}/$attendanceId",
    );
    return response;
  }

  // Restore attendance
  Future<Response> restoreAttendance({required int attendanceId}) async {
    final response = await ApiServices.patch(
      "${ApiEndpoints.attendance}/$attendanceId",
    );
    return response;
  }
}
