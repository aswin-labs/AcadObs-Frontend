import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class TimeTableServices {
  Future<Response> fetchTimeTable({
    int? studentId,
    required bool forStaff,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? ApiEndpoints.getTodayTimetableForStaff
          : '${ApiEndpoints.fetchTimeTable}/$studentId',
    );
    return response;
  }

  //getAllDayTimeTableByStudentId
  Future<Response> getAllDayTimeTableByStudentId({
    int? studentId,
    required bool forStaff,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? ApiEndpoints.getAllDayTimetableForStaff
          : '${ApiEndpoints.fetchAllDayTimeTable}/$studentId',
    );
    return response;
  }
}
