import 'dart:developer';

import 'package:acadobs/features/parents/data/models/notice_model.dart';
import 'package:acadobs/features/parents/data/services/notice_services.dart';
import 'package:flutter/material.dart';

class NoticeProvider extends ChangeNotifier {
  final NoticeServices _noticeServices = NoticeServices();
  List<Notices> _notices = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Notices> get notices => _notices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  Future<void> fetchNotices({int pageNo = 1, bool isRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _noticeServices.fetchNotices(pageNo: pageNo);
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
        } else {
          _notices.addAll(fetched);
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

  void loadMore() {
    if (_hasMore && !_isLoading) {
      fetchNotices(pageNo: _currentPage + 1);
    }
  }
}
