import 'dart:developer';

import 'package:acadobs/features/marks/data/models/marks_model.dart';
import 'package:acadobs/features/teacher/data/services/my_class_services.dart';
import 'package:flutter/material.dart';

class MyClassProvider extends ChangeNotifier {
  bool _isLoadingInternalMarks = false;
  bool _isLoadingMarks = false;

  bool get isLoadingInternalMarks => _isLoadingInternalMarks;
  bool get isLoadingMarks => _isLoadingMarks;

  final List<MarksModel> _marks = [];
  List<MarksModel> get marks => _marks;

  final List<MarksModel> _internalMarks = [];
  List<MarksModel> get internalMarks => _internalMarks;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  int _currentPageInternal = 1;
  int _totalPagesInternal = 1;

  bool get hasMoreInternal => _currentPageInternal < _totalPagesInternal;

  bool _isFetchedOnce = false;
  bool get isTermMarksFetchedOnce => _isFetchedOnce;

  bool _isFetchedOnceInternal = false;
  bool get isInternalMarksFetchedOnce => _isFetchedOnceInternal;

  // get my class term exam marks
  Future<void> fetchMyClassTermExamMarks({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingMarks) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoadingMarks = true;
    notifyListeners();
    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _marks.clear();
        _isFetchedOnce = false;
      }
      final response = await MyClassServices().fetchMyClassMarks(
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List marksJson = data['exams'];

        final List<MarksModel> fetchMarks =
            marksJson.map((jsonItem) => MarksModel.fromJson(jsonItem)).toList();

        _marks.addAll(fetchMarks);
        _isFetchedOnce = true;
      } else {
        throw Exception('Failed to fetch marks: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingMarks = false;
      notifyListeners();
    }
  }

  // Get my class internal marks
  Future<void> fetchMyClassInternalMarks({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingInternalMarks) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnceInternal) return;

    _isLoadingInternalMarks = true;
    notifyListeners();
    try {
      if (loadMore) {
        _currentPageInternal++;
      } else {
        _currentPageInternal = 1;
        _internalMarks.clear();
        _isFetchedOnceInternal = false;
      }
      final response = await MyClassServices().fetchMyClassInternalMarks(
        pageNo: _currentPageInternal,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPagesInternal = data['totalPages'];
        _currentPageInternal = data['currentPage'];

        final List internalMarksJson = data['exams'];

        final List<MarksModel> fetchMarks =
            internalMarksJson
                .map((jsonItem) => MarksModel.fromJson(jsonItem))
                .toList();

        _internalMarks.addAll(fetchMarks);
        _isFetchedOnceInternal = true;
      } else {
        throw Exception(
          'Failed to fetch internalMarks: ${response.statusCode}',
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingInternalMarks = false;
      notifyListeners();
    }
  }
}
