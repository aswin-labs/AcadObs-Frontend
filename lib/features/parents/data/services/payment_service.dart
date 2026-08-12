import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/file_upload_utils.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentService {
  // fetch payments
  Future<Response> fetchPayments({
    required int pageNo,
    required int studentId,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.studentPayment}/$studentId?pageNo=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }

  // fetch invoices
  Future<Response> fetchInvoices({
    required int studentId,
    required int pageNo,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.studentInvoices}/$studentId?pageNo=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }

  // upload payment details
  Future<Response> uploadPaymentDetails({
    required BuildContext context,
    required int studentId,
    required int invoiceStudentId,
    required double amount,
    required String paymentDate,
    required String paymentCategory,
    required String transactionId,
    required String paymentMethod,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(
      'paymentAttachment',
    );

    final multipartFile = await FileUploadUtils.toMultipartFile(fileUpload);

    final formData = FormData.fromMap({
      "student_id": studentId,
      "invoice_student_id": invoiceStudentId,
      "amount": amount,
      "payment_date": paymentDate,
      "payment_category": paymentCategory,
      "transaction_id": transactionId,
      "payment_method": paymentMethod,
      if (multipartFile != null) "payment_attachment": multipartFile,
    });
    final response = await ApiServices.post(
      ApiEndpoints.uploadPaymentDetails,
      formData,
      isFormData: true,
    );

    return response;
  }

  // update payment details
  Future<Response> editPaymentDetails({
    required BuildContext context,
    required int paymentId,
    required int studentId,
    required int invoiceStudentId,
    required double amount,
    required String paymentDate,
    required String paymentCategory,
    required String transactionId,
    required String paymentMethod,
  }) async {
    final fileUpload = context.read<FilePickerProvider>().getFile(
      'paymentAttachment',
    );

    final multipartFile = await FileUploadUtils.toMultipartFile(fileUpload);

    final formData = FormData.fromMap({
      "student_id": studentId,
      "invoice_student_id": invoiceStudentId,
      "amount": amount,
      "payment_date": paymentDate,
      "payment_category": paymentCategory,
      "transaction_id": transactionId,
      "payment_method": paymentMethod,
      if (multipartFile != null) "payment_attachment": multipartFile,
    });
    final response = await ApiServices.put(
      "${ApiEndpoints.uploadPaymentDetails}/$paymentId",
      formData,
      isFormData: true,
    );

    return response;
  }
}
