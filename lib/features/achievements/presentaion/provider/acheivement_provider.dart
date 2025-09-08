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

  AchievementModel? model;

  // bool _hasMore = true;
  bool get hasMore => _currentPage < _totalPages;

  List<AchievementModel> get todayAchievement {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _achievements.where((a) {
      if (a.date == null) return false;
      final d = DateTime(a.date!.year, a.date!.month, a.date!.day);
      return d == today;
    }).toList();
  }

  List<AchievementModel> get yesterdayAchievement {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    return _achievements.where((a) {
      if (a.date == null) return false;
      final d = DateTime(a.date!.year, a.date!.month, a.date!.day);
      return d == yesterday;
    }).toList();
  }

  List<AchievementModel> get earlierAchievement {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    return _achievements.where((a) {
      if (a.date == null) return false;
      final d = DateTime(a.date!.year, a.date!.month, a.date!.day);
      return d.isBefore(yesterday);
    }).toList();
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
        await fetchAllAchievements(forceRefresh: true);
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
      final int requestedPage = loadMore ? _currentPage + 1 : 1;

      if (!loadMore) {
        _currentPage = 1;
        _achievements.clear();
        _isFetchedOnce = false;
      }

      final response = await AchievementService().fetchALlAchievement(
        pageNo: requestedPage,
      );

      log("Fetch response: ${response.data}, Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'] ?? 1;
        _currentPage = requestedPage;
        final List achievements = data['achievements'] ?? [];
        final List<AchievementModel> fetchedAchievements = [];
        for (var jsonItem in achievements) {
          try {
            final model = AchievementModel.fromJson(jsonItem);

            fetchedAchievements.add(model);
          } catch (e) {
            log("Error parsing achievement: $e, JSON: $jsonItem");
          }
        }
        for (final newItem in fetchedAchievements) {
          if (!_achievements.any((a) => a.id == newItem.id)) {
            _achievements.add(newItem);
          }
        }

        _achievements.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

        _isFetchedOnce = true;
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

  //edit achievement
  Future<void> editAchievement({
    required BuildContext context,

    required String title,
    required String description,

    required int achievementId,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await AchievementService().editAchievement(
        achievementId: achievementId,

        title: title,
        description: description,
      );

      if (response.statusCode == 200) {
        await fetchAllAchievements(forceRefresh: true);
        if (!context.mounted) return;
        Navigator.pop(context);
        // Navigator.pop(context);
        final updatedData = response.data['achievements'];

        model?.title = updatedData['title'];
        model?.description = updatedData['description'];

        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: 'achievements details saved',
          type: SnackbarType.success,
        );
      } else if (response.statusCode == 400) {
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: '${response.data["error"]}. cant update',
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log('error: ${e.toString()}');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  //delete achievement
  Future<bool> deleteAchievement(int id) async {
    try {
      final response = await AchievementService().deleteAchievement(
        achievementId: id,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _achievements.removeWhere((n) => n.id == id);
        notifyListeners();
        return true; // success
      } else {
        log('Failed to delete achievement: ${response.statusCode}');
        return false; // failed
      }
    } catch (e) {
      log('Error deleting achievement: $e');
      return false; // failed
    }
  }
}
