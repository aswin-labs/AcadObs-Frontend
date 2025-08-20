import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class NewsService {
  final schoolId = StorageServices.getSchoolId;

  Future<Response> fetchLatestNews({
    required bool forStaff,
    required int pageNo,
    required int limit,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? '${ApiEndpoints.fetchLatestNews}?pageNo=$pageNo&limit=$limit'
          : '${ApiEndpoints.fetchLatestNewsGuardian}?pageNo=$pageNo&limit=$limit',
    );
    return response;
  }
}
