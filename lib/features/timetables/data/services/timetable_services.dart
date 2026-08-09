import 'package:acadobs/features/timetables/data/models/timetable_type.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/api_services.dart';
import '../../../../core/utils/urls/api_end_points.dart';

class TimetableServices {
  // fetch today timetable for staff, my class, and student
  Future<Response> fetchTodayTimetable({
    required TimetableType type,
    int? studentId,
  }) {
    switch (type) {
      case TimetableType.teacher:
        return ApiServices.get(ApiEndpoints.getTodayTimetableForStaff);

      case TimetableType.myClass:
        return ApiServices.get(ApiEndpoints.getMyClassTodayTimetable);

      case TimetableType.student:
        return ApiServices.get(
          "${ApiEndpoints.getTodayTimeTableByStudentId}/$studentId",
        );
    }
  }

  // fetch all day timetable for staff, my class, and student
  Future<Response> fetchAllDayTimetable({
    required TimetableType type,
    int? studentId,
  }) {
    switch (type) {
      case TimetableType.teacher:
        return ApiServices.get(ApiEndpoints.getAllDayTimetableForStaff);

      case TimetableType.myClass:
        return ApiServices.get(ApiEndpoints.getMyClassAllDayTimetable);

      case TimetableType.student:
        return ApiServices.get(
          "${ApiEndpoints.getAllDayTimeTableByStudentId}/$studentId",
        );
    }
  }
}
