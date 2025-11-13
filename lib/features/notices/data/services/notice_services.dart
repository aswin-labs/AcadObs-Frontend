import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class NoticeServices {
  // Fetch notices - GET
  Future<Response> fetchNotices({
    required int pageNo,
    required int limit,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.fetchLatestNotices}?page=$pageNo&limit=$limit',
    );
    return response;
  }
}
