import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class EventServices {
  final int _schoolId = 1;

  Future<Response> fetchEvents({required int pageNo}) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.fetchEvents}?page=$pageNo&school_id=$_schoolId',
      //https://acadobs.altezzai.com/api/s1/schooladmin/events
    );
    return response;
  }
}
