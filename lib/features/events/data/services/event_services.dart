import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class EventServices {
 Future<Response> fetchLatestEvents({
  required int pageNo,
  required int limit,
  required bool forStaff,
}) async {
  String url;

  if (forStaff) {
    url = '${ApiEndpoints.fetchLatestEventsStaff}?page=$pageNo&limit=$limit';
  } else {
    final schoolId = await AuthStorageService().getSchoolIdForParent();
    if (schoolId == null) {
      throw Exception("School ID is null");
    }
    url = '${ApiEndpoints.fetchLatestEventsGuardian}?page=$pageNo&limit=$limit&school_id=$schoolId';
  }

  final response = await ApiServices.get(url);
  return response;
}

}
