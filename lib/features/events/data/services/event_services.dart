import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/storage_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class EventServices {
  final schoolId = StorageServices.getSchoolId;

  //for the staff
  Future<Response> fetchLatestEvents({
    required int pageNo,
    required int limit,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.fetchLatestEventsStaff}?page=$pageNo&limit=$limit',
    );
    return response;
  }

  // for the parents
  Future<Response> fetchLatestEventsGuardian({
    required int limit,
    required int pageNo,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.fetchLatestEventsGuardian}?page=$pageNo&limit=$limit&school_id=$schoolId',
    );
    return response;
  }
}
