import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/parents/data/models/transport_invoice_model.dart';
import 'package:acadobs/features/parents/data/services/transport_payment_services.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TransportPaymentProvider extends ChangeNotifier {
  final TransportPaymentServices _services = TransportPaymentServices();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingDetails = false;
  bool get isLoadingDetails => _isLoadingDetails;

  bool _isLoadingUpload = false;
  bool get isLoadingUpload => _isLoadingUpload;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalContent = 0;
  int get totalContent => _totalContent;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  bool _isFetchedOnce = false;
  bool get isFetchedOnce => _isFetchedOnce;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  final List<TransportInvoice> _transportInvoices = [];
  List<TransportInvoice> get transportInvoices => _transportInvoices;

  TransportInvoice? _selectedInvoice;
  TransportInvoice? get selectedInvoice => _selectedInvoice;

  void setSelectedInvoice(TransportInvoice? invoice) {
    _selectedInvoice = invoice;
    notifyListeners();
  }

  int? _currentStudentId;
  int? get currentStudentId => _currentStudentId;

  // Fetch transport invoices for student
  Future<void> fetchTransportInvoices({
    bool loadMore = false,
    bool forceRefresh = false,
    required int studentId,
  }) async {
    _currentStudentId = studentId;

    if (_isLoading) return;
    if (loadMore && !_hasMore) return;

    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final targetPage = loadMore ? (_currentPage + 1) : 1;
      if (!loadMore) {
        _currentPage = 1;
        _transportInvoices.clear();
        _isFetchedOnce = false;
        _hasMore = true;
        _isAvailable = false;
      }

      final response = await _services.fetchTransportInvoices(
        studentId: studentId,
        pageNo: targetPage,
      );

      log(
        "Transport invoices response: ${response.data}, Status: ${response.statusCode}",
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        _totalPages =
            data['totalPages'] is int
                ? data['totalPages']
                : int.tryParse(data['totalPages']?.toString() ?? '1') ?? 1;

        _currentPage =
            data['currentPage'] is int
                ? data['currentPage']
                : int.tryParse(data['currentPage']?.toString() ?? '1') ?? targetPage;

        _totalContent =
            data['totalcontent'] is int
                ? data['totalcontent']
                : data['totalContent'] is int
                ? data['totalContent']
                : int.tryParse(data['totalcontent']?.toString() ?? '') ??
                    int.tryParse(data['totalContent']?.toString() ?? '0') ??
                    0;

        final rawDataList = data['data'];
        final List listJson = rawDataList is List ? rawDataList : [];
        final List<TransportInvoice> fetched =
            listJson.whereType<Map>().map((item) {
              final map = Map<String, dynamic>.from(item);
              if (map['student_id'] == null && map['studentId'] == null) {
                map['student_id'] = studentId;
              }
              return TransportInvoice.fromJson(map);
            }).toList();

        final ids = _transportInvoices.map((e) => e.id).toSet();
        final newItems = fetched.where((item) => !ids.contains(item.id));

        _transportInvoices.addAll(newItems);
        _isFetchedOnce = true;
        _isAvailable = _transportInvoices.isNotEmpty;

        if (fetched.isEmpty ||
            fetched.length < AppConstants.paginationLimit ||
            _currentPage >= _totalPages) {
          _hasMore = false;
        } else {
          _hasMore = true;
        }
      } else {
        if (loadMore) {
          _hasMore = false;
        }
        _isAvailable = false;
      }
    } on DioException catch (e) {
      log("Error fetching transport invoices: $e");
      if (loadMore) {
        _hasMore = false;
      }
      if (!loadMore) {
        _isAvailable = false;
      }
    } catch (e) {
      log("Unexpected error fetching transport invoices: $e");
      if (loadMore) {
        _hasMore = false;
      }
      if (!loadMore) {
        _isAvailable = false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch single transport invoice details
  Future<void> fetchTransportInvoiceById(int invoiceId) async {
    _isLoadingDetails = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      final response = await _services.fetchTransportInvoiceById(
        invoiceId: invoiceId,
      );

      if (response.statusCode == 200 && response.data != null) {
        final rawData = response.data;
        if (rawData is Map) {
          final data =
              (rawData['data'] is Map)
                  ? Map<String, dynamic>.from(rawData['data'] as Map)
                  : Map<String, dynamic>.from(rawData);

          if (data['student_id'] == null &&
              data['studentId'] == null &&
              _currentStudentId != null) {
            data['student_id'] = _currentStudentId;
          }

          if (rawData['pendingAmount'] != null && data['pendingAmount'] == null) {
            data['pendingAmount'] = rawData['pendingAmount'];
          }
          if (rawData['totalAmountPaid'] != null && data['totalAmountPaid'] == null) {
            data['totalAmountPaid'] = rawData['totalAmountPaid'];
          }

          _selectedInvoice = TransportInvoice.fromJson(data);
        }
      }
    } catch (e) {
      log("Error fetching transport invoice details: $e");
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  // Create transport invoice payment
  Future<void> createTransportPayment({
    required BuildContext context,
    required int studentId,
    required int transportInvoiceId,
    required double amount,
    required String paymentDate,
    required String transactionId,
    required String paymentMethod,
  }) async {
    _isLoadingUpload = true;
    notifyListeners();

    try {
      final response = await _services.createTransportInvoicePayment(
        context: context,
        studentId: studentId,
        transportInvoiceId: transportInvoiceId,
        amount: amount,
        paymentDate: paymentDate,
        transactionId: transactionId,
        paymentMethod: paymentMethod,
      );
      log(response.data.toString());

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchTransportInvoices(studentId: studentId, forceRefresh: true);
        await fetchTransportInvoiceById(transportInvoiceId);
        if (!context.mounted) return;
        await context.read<PaymentProvider>().fetchPayments(
          studentId: studentId,
          forceRefresh: true,
        );

        if (!context.mounted) return;

        final message =
            response.data?['message'] ?? 'Payment submitted successfully';

        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.success,
        );

        Navigator.of(context).pop(); // Close bottomsheet
      }
    } on DioException catch (e) {
      if (!context.mounted) return;

      CustomSnackbar.show(
        context,
        message:
            e.response?.data?['error'] ??
            e.response?.data?['message'] ??
            'Transport payment upload failed',
        type: SnackbarType.failure,
      );
    } catch (e) {
      log("Error uploading transport payment: $e");
      if (!context.mounted) return;

      CustomSnackbar.show(
        context,
        message: 'Something went wrong',
        type: SnackbarType.failure,
      );
    } finally {
      _isLoadingUpload = false;
      notifyListeners();
    }
  }
}
