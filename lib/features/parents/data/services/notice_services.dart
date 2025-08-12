import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class NoticeServices {
  // final int _schoolId = 1;

  Future<Response> fetchLatestNotices({required int pageNo, required int limit}) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.fetchLatestNotices}?page=$pageNo&limit=$limit',
    );
    return response;
  }
}
