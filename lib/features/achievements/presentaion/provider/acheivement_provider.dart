import 'dart:developer';

import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/achievements/data/services/achievement_service.dart';
// import 'package:acadobs/features/students/acheivement/achievement_model.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../../students/acheivement/achievement_model.dart';

class AchievementProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;
  String? _error;
  String? get error => _error;
  final List<AchievementModel> _achievements = [];
  List<AchievementModel> get achievements => _achievements;

  int _currentPage = 1;

  // bool _hasMore = true;
  bool get hasMore => _currentPage < _totalPages;

  //distinguishing today achievements
  List<AchievementModel> get todayAchievement =>
      _achievements.where((e) {
          final now = DateTime.now();
          return now.year == e.date!.year &&
              now.month == e.date!.month &&
              now.day == e.date!.day;
        }).toList()
        ..sort((a, b) => (b.createdAt)!.compareTo(a.createdAt!));

  // Distinguishing yesterday's achievements
  List<AchievementModel> get yesterdayAchievement =>
      _achievements.where((e) {
          final now = DateTime.now();
          final yesterday = now.subtract(Duration(days: 1));
          return yesterday.year == e.date!.year &&
              yesterday.month == e.date!.month &&
              yesterday.day == e.date!.day;
        }).toList()
        ..sort((a, b) => (b.createdAt)!.compareTo(a.createdAt!));

  // Distinguishing earlier achievements
  List<AchievementModel> get earlierAchievement {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return _achievements.where((e) {
        final created = DateTime(e.date!.year, e.date!.month, e.date!.day);
        return created.isBefore(yesterday);
      }).toList()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  Future<bool> createAchievement({
    required BuildContext context,
    required String title,
    required String description,
    required String category,
    required String level,
    required String date,
    required String awardingBody,
    required List<Map<String, dynamic>> students, // Updated parameter
  }) async {
    _isLoadingTwo = true;
    notifyListeners();

    try {
      log("Sending achievement data:");
      log("Title: $title");
      log("Description: $description");
      log("Category: $category");
      log("Level: $level");
      log("Date: $date");
      log("Awarding Body: $awardingBody");
      log("Students: $students");

      final Response response = await AchievementService().createAchievement(
        context: context,
        title: title,
        description: description,
        category: category,
        level: level,
        date: date,
        awardingBody: awardingBody,
        students: students,
      );

      log("the data is : ${response.data}");

      final code = response.statusCode ?? 0;

      if (code == 201 || code == 200) {
        if (!context.mounted) return true;
        CustomSnackbar.show(
          context,
          message: "Achievement Added Successfully",
          type: SnackbarType.success,
        );
        Navigator.pop(context);
        _isLoadingTwo = false;
        notifyListeners();
        return true;
      }

      log("code: $code");

      // Handle validation / bad request
      if (code == 400 || code == 422) {
        final message =
            response.data?['error'] ??
            response.data?['message'] ??
            'Invalid request';
        if (context.mounted) CustomErrorDialog.show(context, message);
        _isLoadingTwo = false;
        notifyListeners();
        return false;
      }

      // Other failures
      final message = response.data?['message'] ?? 'Error occurred';
      if (context.mounted) CustomErrorDialog.show(context, message);
      _isLoadingTwo = false;
      notifyListeners();
      return false;
    } catch (e) {
      // log(e.toString());
      log("Error: $e");
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: "Failed to create achievement: $e",
          type: SnackbarType.failure,
        );
      }
      _isLoadingTwo = false;
      notifyListeners();
      return false;
    }
  }

  bool _isFetchedOnce = false;
  int _totalPages = 1;

  /// Fetch all achievements (paginated)
  Future<void> fetchAllAchievements({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoading = true;
    notifyListeners(); // Notify UI of loading state

    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _achievements.clear();
        _isFetchedOnce = false;
      }
      final response = await AchievementService().fetchALlAchievement(
        pageNo: _currentPage,
      );
      log("Fetch response: ${response.data}, Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'] ?? 1;
        _currentPage = data['currentPage'] ?? 1;
        final List achievements = data['achievements'] ?? [];
        final List<AchievementModel> fetchedAchievements = [];
        for (var jsonItem in achievements) {
          try {
            final model = AchievementModel.fromJson(jsonItem);
            log(
              "Parsed: ${model.title}, Date: ${model.date}, CreatedAt: ${model.createdAt}",
            );
            fetchedAchievements.add(model);
          } catch (e) {
            log("Error parsing achievement: $e, JSON: $jsonItem");
          }
        }
        _achievements.addAll(fetchedAchievements);
        _isFetchedOnce = true;
        log("Total achievements: ${_achievements.length}, Has more: $hasMore");
      } else {
        _error = 'Failed to fetch achievements: ${response.statusCode}';
        log(_error!);
      }
    } catch (e) {
      _error = 'Fetch error: $e';
      log(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
