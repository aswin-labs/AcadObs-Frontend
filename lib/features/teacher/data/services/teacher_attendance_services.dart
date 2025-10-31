import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class TeacherAttendanceServices {
  // get today attendance status
  Future<Response> getTodayAttendanceStatus() async {
    final response = await ApiServices.get(ApiEndpoints.teacherTodayAttendance);
    return response;
  }

  // check in attendance
  Future<Response> checkInAttendance({
    required String latitude,
    required String longitude,
  }) async {
    final response = await ApiServices.post(ApiEndpoints.teacherCheckIn, {
      "latitude": latitude,
      "longitude": longitude,
    });
    return response;
  }

   // check out attendance
  Future<Response> checkOutAttendance({
    required String latitude,
    required String longitude,
  }) async {
    final response = await ApiServices.put(ApiEndpoints.teacherCheckOut, {
      "latitude": latitude,
      "longitude": longitude,
    });
    return response;
  }
}
