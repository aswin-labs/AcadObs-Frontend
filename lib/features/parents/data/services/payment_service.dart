import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';

class PaymentService {
  Future<Response> fetchPayments({
    required int pageNo,
    required int studentId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.studentPayment}/$studentId?pageNo=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }
}
