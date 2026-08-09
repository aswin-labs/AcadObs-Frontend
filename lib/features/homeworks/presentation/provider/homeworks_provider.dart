import 'dart:developer';

import 'package:acadobs/features/homework/data/models/gouped_homework_model.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:acadobs/features/homeworks/data/services/homeworks_services.dart';
import 'package:flutter/widgets.dart';

class HomeworksProvider extends ChangeNotifier {
  bool _isLoadingHomeworks = false;
  bool get isLoadingHomeworks => _isLoadingHomeworks;

  bool _isLoadingSingleHomework = false;
  bool get isLoadingSingleHomework => _isLoadingSingleHomework;

  final List<GroupedHomework> _homeworks = [];
  List<GroupedHomework> get homeworks => _homeworks;

  HomeworkModel? singleHomework;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  // Fetch homeworks
  Future<void> fetchHomeworks({
    required HomeworkViewerType viewerType,
    int? studentId,
    bool loadMore = false,
    bool forceRefresh = false,
    bool forClassTeacher = false,
  }) async {
    if (_isLoadingHomeworks) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh) return;

    _isLoadingHomeworks = true;

    try {
      if (loadMore) {
        if (_currentPage >= _totalPages) {
          _isLoadingHomeworks = false;
          return;
        }
        _currentPage++;
      } else {
        _currentPage = 1;
        _homeworks.clear();
      }
      final response = await HomeworksServices().fetchHomeworks(
        viewerType: viewerType,
        pageNo: _currentPage,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List homeworksJson = data['groupedHomework'];

        final List<GroupedHomework> fetchedHomeworks =
            homeworksJson
                .map((json) => GroupedHomework.fromJson(json))
                .toList();
        _homeworks.addAll(fetchedHomeworks);
      } else {
        throw Exception('Failed to fetch homeworks: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingHomeworks = false;
      notifyListeners();
    }
  }
}
