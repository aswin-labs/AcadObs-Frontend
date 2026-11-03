import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class StudentRouteService {
  Future<Response> getStudentRoutes() async {
    final response = await ApiServices.get(ApiEndpoints.getStudentRoute);
    return response;
  }

  Future<Response> getTodayTransportationByStudentId({
    required int studentId,
    String? date,
  }) async {
    String url =
        '${ApiEndpoints.getTodayTransportationByStudentId}/$studentId';
    if (date != null && date.trim().isNotEmpty) {
      url += '?date=${Uri.encodeComponent(date.trim())}';
    }
    final response = await ApiServices.get(url);
    return response;
  }

  // Future<Response> getRouteCount() async {
  //   final response = await ApiServices.get(ApiEndpoints.getRouteCount);
  //   return response;
  // }

  // //guardians sees arrived stops in routes
  // Future<Response> getStopsForParent({required int routeId}) async {
  //   final response = await ApiServices.get(
  //     '${ApiEndpoints.getStopsForParent}/$routeId',
  //   );
  //   return response;
  // }
}
