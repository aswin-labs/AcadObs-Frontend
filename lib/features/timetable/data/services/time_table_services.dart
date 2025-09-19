import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class TimeTableServices {
  Future<Response> fetchTimeTable({required int studentId}) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.fetchTimeTable}/$studentId',
    );
    return response;
  }

  //getAllDayTimeTableByStudentId
  Future<Response> getAllDayTimeTableByStudentId({
    required int studentId,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.fetchAllDayTimeTable}/$studentId',
    );
    return response;
  }
}
