import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
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

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  bool _isLoadingPaymentDetails = false;
  bool get isLoadingPaymentDetails => _isLoadingPaymentDetails;

  InvoiceStudent? _selectedInvoice;
  InvoiceStudent? get selectedInvoice => _selectedInvoice;

  void clearSelectedInvoice() {
    _selectedInvoice = null;
    notifyListeners();
  }

  Payment? _selectedPayment;
  Payment? get selectedPayment => _selectedPayment;

  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }

  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _currentInvoicePage = 1;
  int _totalInvoicePages = 1;
  bool _hasMoreInvoice = true;
  bool get hasMoreInvoice => _hasMoreInvoice;

  bool _isFetchedOnce = false;
  bool get isFetchedOnce => _isFetchedOnce;

  bool _isFetchedInvoiceOnce = false;
  bool get isFetchedInvoiceOnce => _isFetchedInvoiceOnce;

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
    if (loadMore && !_hasMore) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoadingForPayments = true;

    try {
      final targetPage = loadMore ? (_currentPage + 1) : 1;
      if (!loadMore) {
        _currentPage = 1;
        _payments.clear();
        _isFetchedOnce = false;
        _hasMore = true;
      }
      final response = await PaymentService().fetchPayments(
        pageNo: targetPage,
        studentId: studentId,
      );
      log("API Response: ${response.data}, Status: ${response.statusCode}");
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        final rawTotalPages =
            data['totalPages'] ?? data['total_pages'] ?? data['totalPage'];
        if (rawTotalPages != null) {
          _totalPages = rawTotalPages is int
              ? rawTotalPages
              : int.tryParse(rawTotalPages.toString()) ?? 1;
        }

        final rawCurrentPage =
            data['currentPage'] ?? data['current_page'] ?? data['pageNo'];
        if (rawCurrentPage != null) {
          _currentPage = rawCurrentPage is int
              ? rawCurrentPage
              : int.tryParse(rawCurrentPage.toString()) ?? targetPage;
        } else {
          _currentPage = targetPage;
        }

        final rawList = data['payment'] ?? data['payments'] ?? data['data'];
        final List leavesJson = rawList is List ? rawList : [];

        final List<Payment> fetchedPayments =
            leavesJson
                .whereType<Map>()
                .map((jsonItem) => Payment.fromJson(Map<String, dynamic>.from(jsonItem)))
                .toList();

        //avoids the duplication
        final ids = _payments.map((e) => e.id).toSet();
        final newPayments = fetchedPayments.where(
          (payment) => !ids.contains(payment.id),
        );

        _payments.addAll(newPayments);
        _isFetchedOnce = true;

        if (fetchedPayments.isEmpty ||
            fetchedPayments.length < AppConstants.paginationLimit ||
            _currentPage >= _totalPages) {
          _hasMore = false;
        } else {
          _hasMore = true;
        }
      } else {
        if (loadMore) {
          _hasMore = false;
        }
        throw Exception('Failed to fetch payments: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
      if (loadMore) {
        _hasMore = false;
      }
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
    if (loadMore && !_hasMoreInvoice) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedInvoiceOnce) return;

    _isLoadingForInvoice = true;

    try {
      final targetPage = loadMore ? (_currentInvoicePage + 1) : 1;
      if (!loadMore) {
        _currentInvoicePage = 1;
        _invoices.clear();
        _isFetchedInvoiceOnce = false;
        _hasMoreInvoice = true;
      }
      final response = await PaymentService().fetchInvoices(
        studentId: studentId,
        pageNo: targetPage,
      );
      log(
        "API Response invoices: ${response.data.toString()}, Status: ${response.statusCode}",
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        final rawTotalPages =
            data['totalPages'] ?? data['total_pages'] ?? data['totalPage'];
        if (rawTotalPages != null) {
          _totalInvoicePages = rawTotalPages is int
              ? rawTotalPages
              : int.tryParse(rawTotalPages.toString()) ?? 1;
        }

        final rawCurrentPage =
            data['currentPage'] ?? data['current_page'] ?? data['pageNo'];
        if (rawCurrentPage != null) {
          _currentInvoicePage = rawCurrentPage is int
              ? rawCurrentPage
              : int.tryParse(rawCurrentPage.toString()) ?? targetPage;
        } else {
          _currentInvoicePage = targetPage;
        }

        final rawList = data['invoices'] ?? data['invoice'] ?? data['data'];
        final List leavesJson = rawList is List ? rawList : [];

        final List<InvoiceStudent> fetchedInvoices =
            leavesJson
                .whereType<Map>()
                .map((jsonItem) => InvoiceStudent.fromJson(Map<String, dynamic>.from(jsonItem)))
                .toList();

        //avoids the duplication
        final ids = _invoices.map((e) => e.id).toSet();
        final newInvoices = fetchedInvoices.where(
          (invoice) => !ids.contains(invoice.id),
        );

        _invoices.addAll(newInvoices);
        _isFetchedInvoiceOnce = true;

        if (fetchedInvoices.isEmpty ||
            fetchedInvoices.length < AppConstants.paginationLimit ||
            _currentInvoicePage >= _totalInvoicePages) {
          _hasMoreInvoice = false;
        } else {
          _hasMoreInvoice = true;
        }
      } else {
        if (loadMore) {
          _hasMoreInvoice = false;
        }
        throw Exception('Failed to fetch invoices: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
      if (loadMore) {
        _hasMoreInvoice = false;
      }
    } finally {
      _isLoadingForInvoice = false;
      notifyListeners();
    }
  }

  // Fetch single invoice details by ID
  Future<void> fetchStudentInvoiceById(int invoiceId) async {
    _isLoadingDetails = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await PaymentService().fetchStudentInvoiceById(
        invoiceId: invoiceId,
      );

      log("Student invoice by ID response: ${response.data}, Status: ${response.statusCode}");

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        if (rawData is Map) {
          final data =
              (rawData['data'] is Map)
                  ? Map<String, dynamic>.from(rawData['data'] as Map)
                  : Map<String, dynamic>.from(rawData);

          if (rawData['pendingAmount'] != null && data['pendingAmount'] == null) {
            data['pendingAmount'] = rawData['pendingAmount'];
          }
          if (rawData['totalAmountPaid'] != null && data['totalAmountPaid'] == null) {
            data['totalAmountPaid'] = rawData['totalAmountPaid'];
          }

          _selectedInvoice = InvoiceStudent.fromJson(data);

          // Update cache in _invoices list
          final index = _invoices.indexWhere((inv) => inv.id == _selectedInvoice?.id);
          if (index != -1 && _selectedInvoice != null) {
            _invoices[index] = _selectedInvoice!;
          }
        }
      }
    } catch (e) {
      log("Error fetching student invoice details: $e");
    } finally {
      _isLoadingDetails = false;
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
        await fetchStudentInvoiceById(invoiceStudentId);
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

  // Fetch single payment details by ID
  Future<void> fetchPaymentById(int paymentId) async {
    _isLoadingPaymentDetails = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await PaymentService().fetchPaymentById(
        paymentId: paymentId,
      );

      log("Payment by ID response: ${response.data}, Status: ${response.statusCode}");

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        if (rawData is Map) {
          final data =
              (rawData['data'] is Map)
                  ? Map<String, dynamic>.from(rawData['data'] as Map)
                  : Map<String, dynamic>.from(rawData);

          _selectedPayment = Payment.fromJson(data);

          // Update cache in _payments list if present
          final index =
              _payments.indexWhere((p) => p.id == _selectedPayment?.id);
          if (index != -1 && _selectedPayment != null) {
            _payments[index] = _selectedPayment!;
          }
        }
      }
    } catch (e) {
      log("Error fetching payment details: $e");
    } finally {
      _isLoadingPaymentDetails = false;
      notifyListeners();
    }
  }

  //update payment details
  Future<void> editPaymentDetails({
    required BuildContext context,
    required int paymentId,
    required int studentId,
    int? invoiceStudentId,
    int? transportInvoiceId,
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
        transportInvoiceId: transportInvoiceId,
        amount: amount,
        paymentDate: paymentDate,
        paymentCategory: paymentCategory,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPayments(studentId: studentId, forceRefresh: true);
        if (invoiceStudentId != null) {
          await fetchInvoices(studentId: studentId, forceRefresh: true);
          await fetchStudentInvoiceById(invoiceStudentId);
        }
        await fetchPaymentById(paymentId);

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
