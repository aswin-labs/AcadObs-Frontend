import 'dart:developer';

import 'package:acadobs/features/parents/data/models/notice_model.dart';
import 'package:acadobs/features/notices/data/services/notice_services.dart';
import 'package:flutter/material.dart';

class NoticeProvider extends ChangeNotifier {
  final NoticeServices _noticeServices = NoticeServices();
  List<Notices> _notices = [];
  final List<Notices> _latestnotices = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Notices> get notices => _notices;
  List<Notices> get latestNotices => _latestnotices;

  //distinguishing today event
  List<Notices> get todayEvents =>
      _notices.where((e) {
          final now = DateTime.now();
          return now.year == e.createdAt.year &&
              now.month == e.createdAt.month &&
              now.day == e.createdAt.day;
        }).toList()
        ..sort((a, b) => (b.createdAt).compareTo(a.createdAt));

  //distinguishing yesterday event
  List<Notices> get yesterdayEvents =>
      _notices.where((e) {
          final now = DateTime.now();
          final yesterday = now.subtract(Duration(days: 1));
          return yesterday.year == e.createdAt.year &&
              yesterday.month == e.createdAt.month &&
              yesterday.day == e.createdAt.day;
        }).toList()
        ..sort((a, b) => (b.createdAt).compareTo(a.createdAt));

  //distinguishing earlier event
  List<Notices> get earlierEvents {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return _notices.where((e) {
        final created = DateTime(
          e.createdAt.year,
          e.createdAt.month,
          e.createdAt.day,
        );
        return created.isBefore(yesterday);
      }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  Future<void> fetchLatestNotices({
    int pageNo = 1,
    bool isRefresh = false,
    int limit = 10,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _noticeServices.fetchLatestNotices(
        pageNo: pageNo,
        limit: limit,
      );
      log('full api response is: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data['notices'];

        final totalPages = response.data['totalPages'];

        if (pageNo > totalPages) {
          _hasMore = false;
          _isLoading = false;
          notifyListeners();
          return;
        }

        log("data is $data");

        final fetched = List<Notices>.from(
          data.map((e) => Notices.fromJson(e)),
        );
        fetched.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        if (isRefresh) {
          _notices = fetched;
          _currentPage = 1;
          _hasMore = true;
        } else {
          // _notices.addAll(fetched); updated for the duplication
          final existingIds = _notices.map((e) => e.id).toSet();
          final newNotices =
              fetched.where((e) => !existingIds.contains(e.id)).toList();
          _notices.addAll(newNotices);

          _currentPage = pageNo;
        }
        _hasMore = _currentPage < totalPages;
        _currentPage = pageNo;
      } else {
        _error = 'failed to fetch notices ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchHomeLatestNotices({int limit = 3}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _noticeServices.fetchLatestNotices(
        pageNo: 1,
        limit: limit,
      );
      if (response.statusCode == 200) {
        final data = response.data['notices'];
        final fetched = List<Notices>.from(
          data.map((e) => Notices.fromJson(e)),
        );
        fetched.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        _latestnotices
          ..clear()
          ..addAll(fetched.take(limit));
        notifyListeners();
      } else {
        log("Failed to fetch latest home notices: ${response.statusCode}");
      }
    } catch (e) {
      log("Error in fetchHomeLatestNotices: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMore() {
    if (_hasMore && !_isLoading) {
      fetchLatestNotices(pageNo: _currentPage + 1);
    }
  }
}
