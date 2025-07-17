import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class SharedServices {
  // Get Classes from class standard
  Future<Response> getClassNameFromStandard({required int standard}) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.classesByYear}/$standard',
    );
    return response;
  }
}
