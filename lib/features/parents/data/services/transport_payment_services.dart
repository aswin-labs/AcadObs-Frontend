import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/file_upload_utils.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransportPaymentServices {
  // Fetch transport invoices for a student with pagination
  Future<Response> fetchTransportInvoices({
    required int studentId,
    required int pageNo,
  }) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.transportInvoiceByStudentId}/$studentId?pageNo=$pageNo&limit=${AppConstants.paginationLimit}",
    );
    return response;
  }

  // Fetch single transport invoice details by ID
  Future<Response> fetchTransportInvoiceById({required int invoiceId}) async {
    final response = await ApiServices.get(
      "${ApiEndpoints.transportInvoiceById}/$invoiceId",
    );
    return response;
  }

  // Create transport invoice payment
  Future<Response> createTransportInvoicePayment({
    required BuildContext context,
    required int studentId,
    required int transportInvoiceId,
    required double amount,
    required String paymentDate,
    required String transactionId,
    required String paymentMethod,
  }) async {
    final filePickerProvider = context.read<FilePickerProvider>();
    final fileUpload = filePickerProvider.getFile('transportPaymentAttachment');

    final multipartFile = await FileUploadUtils.toMultipartFile(fileUpload);

    final formData = FormData.fromMap({
      "student_id": studentId,
      "transport_invoice_id": transportInvoiceId,
      "amount": amount,
      "payment_date": paymentDate,
      "transaction_id": transactionId,
      "payment_method": paymentMethod,
      if (multipartFile != null) "payment_attachment": multipartFile,
    });

    final response = await ApiServices.post(
      ApiEndpoints.createTransportInvoicePayment,
      formData,
      isFormData: true,
    );

    return response;
  }
}
