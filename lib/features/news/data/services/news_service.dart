import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class NewsService {
  Future<Response> fetchLatestNews({
    required bool forStaff,
    required int pageNo,
    required int limit,
  }) async {
    String url;

    if (forStaff) {
      url = '${ApiEndpoints.fetchLatestNews}?pageNo=$pageNo&limit=$limit';
    } else {
      final schoolId = await AuthStorageService().getSchoolIdForParent();
      if (schoolId == null) {
        throw Exception("School ID is null");
      }
      url =
          '${ApiEndpoints.fetchLatestNewsGuardian}?pageNo=$pageNo&limit=$limit&school_id=$schoolId';
    }

    final response = await ApiServices.get(url);
    return response;
  }
}
