import 'dart:developer';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class ParentServices {
  Future<Response> fetchStudentsUnderParentBySchoolId() async {
    final schoolId =
        await AuthStorageService().getSchoolIdForParent(); // await here!

    if (schoolId == null) {
      throw Exception("School ID is null");
    }

    final response = await ApiServices.get(
      "${ApiEndpoints.studentsUnderGuardianBySchoolId}/$schoolId",
    );

    log("Student under parent: ${response.data}");
    return response;
  }

  // Get staffs under school
  Future<Response> fetchStaffsUnderSchool({
    required int pageNo,
    String? query,
  }) async {
    final schoolId = await AuthStorageService().getSchoolIdForParent();
    if (schoolId == null) {
      throw Exception("School ID is null");
    }

    // Build the URL conditionally depending on whether query is present
    String url =
        "${ApiEndpoints.staffsBySchoolId}/$schoolId?page=$pageNo&limit=10";
    if (query != null && query.isNotEmpty) {
      url += "&q=$query";
    }

    final response = await ApiServices.get(url);
    return response;
  }
}
