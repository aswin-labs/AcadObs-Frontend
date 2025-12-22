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
}
