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
  Future<Response> fetchStudentDetails({required int studentId}) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.students}/$studentId',
    );
    return response;
  }

  //get attandence by date
  Future<Response> fetchAttendanceByDate({
    required int studentId,
    required String date,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.attendanceByDate}/$studentId?date=$date',
    );
    return response;
  }
}
