import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:dio/dio.dart';

class HomeworksServices {
  // fetch list of homeworks
  Future<Response> fetchHomeworks({
    required HomeworkViewerType viewerType,
    required int pageNo,
    int? studentId,
  }) {
    switch (viewerType) {
      case HomeworkViewerType.teacherView:
        return ApiServices.get(
          "${ApiEndpoints.homeworkByTeacher}?limit=${AppConstants.paginationLimit}&page=$pageNo",
        );

      case HomeworkViewerType.myClassView:
        return ApiServices.get(
          "${ApiEndpoints.myClassHomeworks}?limit=${AppConstants.paginationLimit}&page=$pageNo",
        );

      case HomeworkViewerType.teacherStudentView:
        return ApiServices.get(
          "${ApiEndpoints.homeworksByStudentIdForTeacher}/$studentId?limit=${AppConstants.paginationLimit}&page=$pageNo",
        );
      case HomeworkViewerType.guardianStudentView:
        return ApiServices.get(
          "${ApiEndpoints.homeworksByStudentIdForGuardian}/$studentId?limit=${AppConstants.paginationLimit}&page=$pageNo",
        );
    }
  }

  // fetch Single homework
  Future<Response> fetchSingleHomework({
    required HomeworkViewerType viewerType,
    required homeworkId,
    int? studentId,
  }) {
    switch (viewerType) {
      case HomeworkViewerType.teacherView:
        return ApiServices.get("${ApiEndpoints.homeworks}/$homeworkId");

      case HomeworkViewerType.myClassView:
        return ApiServices.get("${ApiEndpoints.homeworks}/$homeworkId");

      case HomeworkViewerType.teacherStudentView:
        return ApiServices.get(
          "${ApiEndpoints.singleHomeworkByStudentIdForTeacher}/$homeworkId/$studentId",
        );
      case HomeworkViewerType.guardianStudentView:
        return ApiServices.get(
          "${ApiEndpoints.singleHomeworkByStudentIdForGuardian}/$homeworkId/$studentId",
        );
    }
  }
}
