import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/parents/data/models/invoice_student_model.dart';
import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/features/parents/data/services/payment_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoadingForUpload = false;
  bool get isLoadingForUpload => _isLoadingForUpload;

  bool _isLoadingForInvoice = false;
  bool get isLoadingForInvoice => _isLoadingForInvoice;

  bool _isLoadingForEdit = false;
  bool get isLoadingForEdit => _isLoadingForEdit;

  bool _isLoadingForPayments = false;
  bool get isLoadingForPayments => _isLoadingForPayments;

  int _currentPage = 1;
  int _totalPages = 1;

  int _currentInvoicePage = 1;
  int get _totalInvoicePages => 1;

  bool get hasMore => _currentPage < _totalPages;
  bool get hasMoreInvoice => _currentInvoicePage < _totalInvoicePages;

  bool _isFetchedOnce = false;
  bool _isFetchedInvoiceOnce = false;

  final List<Payment> _payments = [];
  List<Payment> get payments => _payments;

  final List<InvoiceStudent> _invoices = [];
  List<InvoiceStudent> get invoices => _invoices;

  //  fetch payments
  Future<void> fetchPayments({
    bool loadMore = false,
    bool forceRefresh = false,
    required int studentId,
  }) async {
    if (_isLoadingForPayments) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoadingForPayments = true;

    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _payments.clear();
        _isFetchedOnce = false;
      }
      final response = await PaymentService().fetchPayments(
        pageNo: _currentPage,
        studentId: studentId,
      );
      log("API Response: ${response.data}, Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = response.data;

        // log("data:$data");

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List leavesJson = data['payment'];

        final List<Payment> fetchedPayments =
            leavesJson.map((jsonItem) => Payment.fromJson(jsonItem)).toList();

        //avoids the duplication
        final ids = _payments.map((e) => e.id).toSet();
        final newPayments = fetchedPayments.where(
          (payment) => !ids.contains(payment.id),
        );

        _payments.addAll(newPayments);
        _isFetchedOnce = true;
      } else {
        throw Exception('Failed to fetch payments: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingForPayments = false;
      notifyListeners();
    }
  }

  // fetch invoices
  Future<void> fetchInvoices({
    bool loadMore = false,
    bool forceRefresh = false,
    required int studentId,
  }) async {
    if (_isLoadingForInvoice) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedInvoiceOnce) return;

    _isLoadingForInvoice = true;

    try {
      if (loadMore) {
        _currentInvoicePage++;
      } else {
        _currentInvoicePage = 1;
        _invoices.clear();
        _isFetchedInvoiceOnce = false;
      }
      final response = await PaymentService().fetchInvoices(
        studentId: studentId,
        pageNo: _currentInvoicePage,
      );
      log(
        "API Response invoices: ${response.data.toString()}, Status: ${response.statusCode}",
      );
      if (response.statusCode == 200) {
        final data = response.data;

        // log("data:$data");

        final List leavesJson = data['invoices'];

        final List<InvoiceStudent> fetchedInvoices =
            leavesJson
                .map((jsonItem) => InvoiceStudent.fromJson(jsonItem))
                .toList();

        //avoids the duplication
        final ids = _invoices.map((e) => e.id).toSet();
        final newInvoices = fetchedInvoices.where(
          (invoice) => !ids.contains(invoice.id),
        );

        _invoices.addAll(newInvoices);
        _isFetchedInvoiceOnce = true;
      } else {
        throw Exception('Failed to fetch invoices: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingForInvoice = false;
      notifyListeners();
    }
  }

  //upload payment details
  Future<void> uploadPaymentDetails({
    required BuildContext context,
    required int studentId,
    required int invoiceStudentId,
    required double amount,
    required String paymentDate,
    required String paymentCategory,
    required String transactionId,
    required String paymentMethod,
  }) async {
    _isLoadingForUpload = true;
    notifyListeners();
    try {
      final response = await PaymentService().uploadPaymentDetails(
        context: context,
        studentId: studentId,
        invoiceStudentId: invoiceStudentId,
        amount: amount,
        paymentDate: paymentDate,
        paymentCategory: paymentCategory,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPayments(studentId: studentId, forceRefresh: true);
        await fetchInvoices(studentId: studentId, forceRefresh: true);
        if (!context.mounted) return;
        final message = response.data['message'];

        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.success,
        );

        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } on DioException catch (e) {
      log('Status Code: ${e.response?.statusCode}');
      log('Response Data: ${e.response?.data}');
      log('Request Data: ${e.requestOptions.data}');

      if (!context.mounted) return;

      CustomSnackbar.show(
        context,
        message: e.response?.data?['error'] ?? 'Payment upload failed',
        type: SnackbarType.failure,
      );
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingForUpload = false;
      notifyListeners();
    }
  }

  //update payment details
  Future<void> editPaymentDetails({
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
    _isLoadingForEdit = true;
    notifyListeners();
    try {
      final response = await PaymentService().editPaymentDetails(
        context: context,
        paymentId: paymentId,
        studentId: studentId,
        invoiceStudentId: invoiceStudentId,
        amount: amount,
        paymentDate: paymentDate,
        paymentCategory: paymentCategory,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPayments(studentId: studentId, forceRefresh: true);
        await fetchInvoices(studentId: studentId, forceRefresh: true);
        if (!context.mounted) return;
        final message = response.data['message'];

        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.success,
        );

        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    } on DioException catch (e) {
      log('Status Code: ${e.response?.statusCode}');
      log('Response Data: ${e.response?.data}');
      log('Request Data: ${e.requestOptions.data}');

      if (!context.mounted) return;

      CustomSnackbar.show(
        context,
        message: e.response?.data?['error'] ?? 'Payment upload failed',
        type: SnackbarType.failure,
      );
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingForEdit = false;
      notifyListeners();
    }
  }
}
