import 'dart:developer';

import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/features/parents/data/services/payment_service.dart';
import 'package:flutter/material.dart';

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // bool _isLoadingTwo = false;
  // bool get isLoadingTwo => _isLoadingTwo;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  final List<Payment> _payments = [];
  List<Payment> get payments => _payments;

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
}
