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
    String? routeType,
  }) async {
    final queryParams = <String, String>{};
    if (date != null && date.trim().isNotEmpty) {
      queryParams['date'] = date.trim();
    }
    if (routeType != null && routeType.trim().isNotEmpty) {
      queryParams['routeType'] = routeType.trim().toUpperCase();
    }

    String url =
        '${ApiEndpoints.getTodayTransportationByStudentId}/$studentId';
    if (queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map(
            (e) =>
                '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
          )
          .join('&');
      url += '?$queryString';
    }
    final response = await ApiServices.get(url);
    return response;
  }
}
