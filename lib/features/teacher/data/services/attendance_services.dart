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
      '${ApiEndpoints.attendanceByTeacher}?teacher_id=$_teacherId&page=$pageNo&limit=10&date=$date',
    );
    return response;
  }
}
