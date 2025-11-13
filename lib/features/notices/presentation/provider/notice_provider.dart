import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/features/notices/data/models/notice_model.dart';
import 'package:acadobs/features/notices/data/services/notice_services.dart';
import 'package:flutter/material.dart';

class NoticeProvider extends ChangeNotifier {
  // ===========================================================================
  // COMMON STATE
  // ===========================================================================
  String? _error;
  String? get error => _error;

  void clearError() => _error = null;

  // ===========================================================================
  // LOADING STATES
  // ===========================================================================
  bool _isLoading = false; // For all notices (paginated)
  bool get isLoading => _isLoading;

  bool _isLatestLoading = false; // For latest notices (home)
  bool get isLatestLoading => _isLatestLoading;

  // ===========================================================================
  // PAGINATED NOTICES (ALL)
  // ===========================================================================
  final List<NoticeModel> _noticesAll = [];
  List<NoticeModel> get noticesAll => List.unmodifiable(_noticesAll);

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  Future<void> fetchNotices({
    bool loadMore = false,
    bool forceRefresh = false,
    int limit = AppConstants.paginationLimit, // Default = 13
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      // Reset when not loading more or forcing refresh
      if (!loadMore || forceRefresh) {
        _currentPage = 1;
        _noticesAll.clear();
      }

      final response = await NoticeServices().fetchNotices(
        pageNo: _currentPage,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'] ?? 1;
        _currentPage = data['currentPage'] ?? 1;

        final fetched =
            (data['notices'] as List)
                .map((e) => NoticeModel.fromJson(e))
                .toList();

        _noticesAll.addAll(fetched);

        if (_currentPage < _totalPages) {
          _currentPage++;
        }
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching notices: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // LATEST NOTICES (HOME)
  // ===========================================================================
  final List<NoticeModel> _noticesLatest = [];
  List<NoticeModel> get noticesLatest => List.unmodifiable(_noticesLatest);

  Future<void> fetchLatestNotices({int limit = 3}) async {
    if (_isLatestLoading) return;
    _isLatestLoading = true;
    notifyListeners();

    try {
      _noticesLatest.clear();

      final response = await NoticeServices().fetchNotices(
        pageNo: 1,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final fetched =
            (data['notices'] as List)
                .map((e) => NoticeModel.fromJson(e))
                .toList();

        _noticesLatest.addAll(fetched);
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching latest notices: $_error");
    } finally {
      _isLatestLoading = false;
      notifyListeners();
    }
  }
}
