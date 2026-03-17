import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class StudentRouteService {
  Future<Response> getStudentRoutes() async {
    final response = await ApiServices.get(ApiEndpoints.getStudentRoute);
    return response;
  }

  Future<Response> getRouteCount() async {
    final response = await ApiServices.get(ApiEndpoints.getRouteCount);
    return response;
  }

  //guardians sees arrived stops in routes
  Future<Response> getStopsForParent({required int routeId}) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.getStopsForParent}/$routeId',
    );
    return response;
  }
}
