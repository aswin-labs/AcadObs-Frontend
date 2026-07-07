import 'dart:developer';
import 'dart:io';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/parents/data/models/invoice_model.dart';
import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/features/parents/data/services/payment_service.dart';
import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingForInvoice = false;
  bool get isLoadingForInvoice => _isLoadingForInvoice;

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

  final List<InvoiceModel> _invoices = [];
  List<InvoiceModel> get invoices => _invoices;

//  fetch payments
  Future<void> fetchPayments({
    bool loadMore = false,
    bool forceRefresh = false,
    required int studentId,
  }) async {
    if (_isLoading) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoading = true;

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
      _isLoading = false;
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
      );
      log("API Response invoices: ${response.data}, Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = response.data;

        // log("data:$data");

        final List leavesJson = data['invoices'];

        final List<InvoiceModel> fetchedInvoices =
            leavesJson.map((jsonItem) => InvoiceModel.fromJson(jsonItem)).toList();

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
    required int amount,
    required String paymentDate,
    required String paymentType,
    required String transactionId,
    required String paymentMethod,
    File? paymentAttachment,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await PaymentService().uploadPaymentDetails(
        studentId: studentId,
        invoiceStudentId: invoiceStudentId,
        amount: amount,
        paymentDate: paymentDate,
        paymentType: paymentType,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
        paymentAttachment: paymentAttachment,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        log('uploaded successfull');
        log(response.data.toString());
        final message = response.data['message'];
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.success,
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
