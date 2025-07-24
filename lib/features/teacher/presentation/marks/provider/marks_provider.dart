import 'dart:developer';

import 'package:acadobs/features/teacher/data/models/marks/marks_model.dart';
import 'package:acadobs/features/teacher/data/services/marks_services.dart';
import 'package:flutter/material.dart';

class MarksProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<MarksModel> _marks = [];
  List<MarksModel> get marks => _marks;


  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  // Fetch marks
  Future<void> fetchAddedMarks({
    bool loadMore = false,
    bool forceRefresh = false,
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
        _marks.clear();
        _isFetchedOnce = false;
      }
      final response = await MarksServices().fetchMarksAddedByTeacher(
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List marksJson = data['exams'];

        final List<MarksModel> fetchHomeworks =
            marksJson
                .map((jsonItem) => MarksModel.fromJson(jsonItem))
                .toList();

        _marks.addAll(fetchHomeworks);
        _isFetchedOnce = true;
      } else {
        throw Exception('Failed to fetch marks: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}