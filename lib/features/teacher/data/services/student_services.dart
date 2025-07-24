import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class StudentServices {
   // Get students from classId
  Future<Response> fetchStudentsByClassId({required int classId, required int pageNo}) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.studentsByClassId}/$classId?limit=${AppConstants.paginationLimit}&page=$pageNo',
    );
    return response;
  }

  // Get individual student details
  Future<Response> fetchStudentDetails({required int studentId}) async {
    final response = await ApiServices.get('${ApiEndpoints.students}/$studentId');
    return response;
  }

}