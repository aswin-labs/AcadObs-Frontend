import 'package:acadobs/features/achievements/data/services/achievement_service.dart';
import 'package:acadobs/features/achievements/models/student_achievement_model.dart';

import 'package:flutter/material.dart';

class StudentAchievementProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<StudentAchievementModel> _achievementModel = [];
  bool _hasMore = true;
  int _currentPage = 1;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;

  List<StudentAchievementModel> get achievementModel => _achievementModel;

  final AchievementService _acheivementService = AchievementService();

  Future<void> fetchAchievementByStudentId({
    int pageNo = 1,
    required bool forStaff,
    bool isRefresh = false,
    int limit = 10,
    required int studentId,
  }) async {
    if (_isLoading && !isRefresh) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _acheivementService.fetchAchievementByStudentId(
        pageNo: pageNo,
        limit: limit,
        forStaff: forStaff,
        studentId: studentId,
      );
      if (response.statusCode == 200) {
        final raw = response.data;

        final int totalPages =
            (raw is Map<String, dynamic> && raw['totalPages'] is int)
                ? raw['totalPages'] as int
                : 1;

        if (pageNo > totalPages) {
          _hasMore = false;
          _isLoading = false;
          notifyListeners();
          return;
        }

        final achievementsRaw =
            (raw is Map<String, dynamic>) ? raw['achievement'] : null;

        final List achievementsList =
            (achievementsRaw is List) ? achievementsRaw : const [];

        final List<StudentAchievementModel> fetched =
            achievementsList
                .map<StudentAchievementModel>(
                  (e) => StudentAchievementModel.fromJson(
                    (e as Map).cast<String, dynamic>(),
                  ),
                )
                .toList();

        if (isRefresh) {
          _achievementModel = fetched;
          _currentPage = 1;
          _hasMore = totalPages > 1;
        } else {
          final existingIds = _achievementModel.map((e) => e.id).toSet();
          final newOnes =
              fetched.where((e) => !existingIds.contains(e.id)).toList();
          _achievementModel.addAll(newOnes);
          _currentPage = pageNo;
          _hasMore = _currentPage < totalPages;
        }
      } else {
        _error = 'failed to fetch ${response.statusCode}';
      }
    } catch (e) {
      _error = 'error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMore({required bool forStaff, required int studentId}) {
    if (_hasMore && !_isLoading) {
      fetchAchievementByStudentId(
        pageNo: _currentPage + 1,
        forStaff: forStaff,
        studentId: studentId,
      );
    }
  }
}
