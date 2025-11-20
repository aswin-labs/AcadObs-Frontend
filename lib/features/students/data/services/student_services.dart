import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class StudentServices {
  // Get students from classId
  Future<Response> fetchStudentsByClassId({required int classId}) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.studentsByClassId}/$classId',
    );
    return response;
  }

  // Get individual student details
  Future<Response> fetchStudentDetails({
    required int studentId,
    required bool forStaff,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? '${ApiEndpoints.students}/$studentId'
          : '${ApiEndpoints.guardian}/$studentId',
    );
    return response;
  }

  //get attandence by date
  Future<Response> fetchAttendanceByDate({
    required int studentId,
    required String date,
    required bool forStaff,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? '${ApiEndpoints.attendanceByDateForStaff}/$studentId?date=$date'
          : '${ApiEndpoints.attendanceByDateForGuardian}/$studentId?date=$date',
    );
    return response;
  }

  //get notice by student id
  Future<Response> fetchNoticeByStudentId({
    required int pageNo,
    required int studentId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.studentNotices}/$studentId?pageNo=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }
}
