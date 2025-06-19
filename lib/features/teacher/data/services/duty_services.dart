import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api/api_end_points.dart';
import 'package:dio/dio.dart';

class DutyServices {
  // Fetch Staff Duties
  Future<Response> fetchStaffDuties({
    required int pageNo,
    required int staffId,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.staffDuties}?page=$pageNo&staff_id=$staffId',
    );
    return response;
  }
}
