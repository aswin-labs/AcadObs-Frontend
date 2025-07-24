import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class MarksServices {
  // fetch marks added by teacher
  final int teacherId = 3;
  Future<Response> fetchMarksAddedByTeacher({required int pageNo}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.marksAddedByTeacher}?recorded_by=$teacherId&limit=${AppConstants.paginationLimit}&page=$pageNo",
    );
    return response;
  }
}
