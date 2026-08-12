import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';

import 'package:acadobs/features/news/data/models/news_model.dart';
import 'package:acadobs/features/news/data/services/news_service.dart';
import 'package:flutter/material.dart';

class NewsProvider extends ChangeNotifier {
  // ===========================================================================
  // COMMON STATE
  // ===========================================================================
  String? _error;
  String? get error => _error;

  void clearError() => _error = null;

  // ===========================================================================
  // LOADING STATES
  // ===========================================================================
  bool _isLoading = false; // For all news (paginated)
  bool get isLoading => _isLoading;

  bool _isLatestLoading = false; // For latest news (home)
  bool get isLatestLoading => _isLatestLoading;

  // ===========================================================================
  // PAGINATED NEWS (ALL)
  // ===========================================================================
  final List<News> _newsAll = [];
  List<News> get newsAll => List.unmodifiable(_newsAll);

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  Future<void> fetchNews({
    required bool forStaff,
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
        _newsAll.clear();
      }

      final response = await NewsService().fetchNews(
        forStaff: forStaff,
        pageNo: _currentPage,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'] ?? 1;
        _currentPage = data['currentPage'] ?? 1;

        final fetched =
            (data['news'] as List).map((e) => News.fromJson(e)).toList();

        _newsAll.addAll(fetched);

        if (_currentPage < _totalPages) {
          _currentPage++;
        }
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching news: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // LATEST EVENTS (HOME)
  // ===========================================================================
  final List<News> _newsLatest = [];
  List<News> get newsLatest => List.unmodifiable(_newsLatest);

  Future<void> fetchLatestNews({required bool forStaff, int limit = 3}) async {
    if (_isLatestLoading) return;
    _isLatestLoading = true;
    notifyListeners();

    try {
      _newsLatest.clear();

      final response = await NewsService().fetchNews(
        forStaff: forStaff,
        pageNo: 1,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final fetched =
            (data['news'] as List).map((e) => News.fromJson(e)).toList();

        _newsLatest.addAll(fetched);
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching latest news: $_error");
    } finally {
      _isLatestLoading = false;
      notifyListeners();
    }
  }
}


