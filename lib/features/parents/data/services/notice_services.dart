import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class NoticeServices {
  final int _schoolId = 1;

  Future<Response> fetchNotices({required int pageNo}) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.fetchNotices}?page=$pageNo&school_id=$_schoolId',
    );
    return response;
  }
}
