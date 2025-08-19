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
    required bool forStaff,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? '${ApiEndpoints.fetchLatestEventsStaff}?page=$pageNo&limit=$limit'
          : '${ApiEndpoints.fetchLatestEventsGuardian}?page=$pageNo&limit=$limit',
    );
    return response;
  }
}
