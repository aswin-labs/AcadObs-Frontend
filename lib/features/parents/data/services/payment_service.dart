import 'dart:io';

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

  Future<Response> uploadPaymentDetails({
    required int studentId,
    required int invoiceStudentId,
    required int amount,
    required String paymentDate,
    required String paymentType,
    required String transactionId,
    required String paymentMethod,
    File? paymentAttachment,
  }) async {
    final Map<String, dynamic> data = {
      "student_id": studentId,
      "invoice_student_id": invoiceStudentId,
      "amount": amount,
      "payment_date": paymentDate,
      "payment_type": paymentType,
      "transaction_id": transactionId,
      "payment_method": paymentMethod,
    };
    if (paymentAttachment != null) {
      data["payment_attachment"] = await MultipartFile.fromFile(
        paymentAttachment.path,
        filename: paymentAttachment.path.split('/').last,
      );
    }

    final response = await ApiServices.post(
      ApiEndpoints.uploadPaymentDetails,
      data,
      isFormData: true,
    );

    return response;
  }
}
