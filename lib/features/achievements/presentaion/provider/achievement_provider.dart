import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/achievements/data/services/achievement_service.dart';
import 'package:acadobs/features/achievements/models/achievement_model.dart';
import 'package:acadobs/features/achievements/models/student_achievement_model.dart';
import 'package:flutter/material.dart';

class AchievementProvider extends ChangeNotifier {
  // ===========================================================================
  // COMMON STATE
  // ===========================================================================
  String? _error;
  String? get error => _error;

  AchievementModel? singleAchievement;

  void clearError() => _error = null;

  // ===========================================================================
  // LOADING STATES
  // ===========================================================================
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingSecondary = false;
  bool get isLoadingSecondary => _isLoadingSecondary;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  // ===========================================================================
  // TEACHER ACHIEVEMENTS
  // ===========================================================================
  final List<AchievementModel> _teacherAchievements = [];
  List<AchievementModel> get teacherAchievements =>
      List.unmodifiable(_teacherAchievements);

  int _teacherPage = 1;
  int _teacherTotalPages = 1;

  bool _isLoadingTeacher = false;
  bool get isLoadingTeacher => _isLoadingTeacher;

  bool hasMoreTeacher = true;
  // bool _isFetchedOnce = false;

  Future<void> fetchAchievementsAddedByTeacher({
    bool loadMore = false,
    bool forceRefresh = false,
    int? limit,
  }) async {
    if (_isLoadingTeacher) return;

    // If not loading more, reset everything
    if (!loadMore || forceRefresh) {
      _teacherPage = 1;
      hasMoreTeacher = true;
      _teacherAchievements.clear();
    }

    // If no more pages, do NOT call API again
    if (!hasMoreTeacher) return;

    _isLoadingTeacher = true;
    notifyListeners();

    try {
      final response = await AchievementService()
          .fetchAchievementsAddedByTeacher(
            pageNo: _teacherPage,
            limit: limit ?? AppConstants.paginationLimit,
          );

      if (response.statusCode == 200) {
        final data = response.data;

        _teacherTotalPages = data['totalPages'] ?? 1;
        final currentPage = data['currentPage'] ?? _teacherPage;

        final fetched =
            (data['achievements'] as List)
                .map((e) => AchievementModel.fromJson(e))
                .toList();

        _teacherAchievements.addAll(fetched);

        // Pagination logic
        hasMoreTeacher = currentPage < _teacherTotalPages;

        if (hasMoreTeacher) {
          _teacherPage = currentPage + 1;
        }
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching teacher achievements: $_error");
    } finally {
      _isLoadingTeacher = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // STUDENT ACHIEVEMENTS
  // ===========================================================================
  final List<StudentAchievementModel> _studentAchievements = [];
  List<StudentAchievementModel> get studentAchievements =>
      List.unmodifiable(_studentAchievements);

  int _studentPage = 1;
  int _studentTotalPages = 1;
  bool _isLoadingStudent = false;
  bool get isLoadingStudent => _isLoadingStudent;
  bool hasMoreStudent = true;

  Future<void> fetchAchievementsByStudentId({
    required int studentId,
    required bool forStaff,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingStudent) return;
    _isLoadingStudent = true;
    notifyListeners();

    try {
      if (!loadMore || forceRefresh) {
        _studentPage = 1;
        hasMoreStudent = true;
        _studentAchievements.clear();
      }

      final response = await AchievementService().fetchAchievementsByStudentId(
        studentId: studentId,
        pageNo: _studentPage,
        forStaff: forStaff,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _studentTotalPages = data['totalPages'] ?? 1;
        _studentPage = data['currentPage'] ?? 1;

        final fetched =
            (data['achievement'] as List)
                .map((e) => StudentAchievementModel.fromJson(e))
                .toList();

        _studentAchievements.addAll(fetched);

        if (_studentPage < _studentTotalPages) {
          _studentPage++;
        }
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching student achievements: $_error");
    } finally {
      _isLoadingStudent = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // SCHOOL ACHIEVEMENTS
  // ===========================================================================
  final List<AchievementModel> _schoolAchievementsLatest = [];
  List<AchievementModel> get schoolAchievementsLatest =>
      List.unmodifiable(_schoolAchievementsLatest);

  final List<AchievementModel> _schoolAchievementsAll = [];
  List<AchievementModel> get schoolAchievementsAll =>
      List.unmodifiable(_schoolAchievementsAll);

  int _schoolCurrentPage = 1;
  int _schoolTotalPages = 1;
  bool get hasMoreForSchool => _schoolCurrentPage < _schoolTotalPages;
  bool _isLoadingSchoolAll = false;
  bool get isLoadingSchoolAll => _isLoadingSchoolAll;

  bool _isFetchedOnceForSchool = false;

  Future<void> fetchSchoolAchievements({
    required bool forStaff,
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingSchoolAll) return;
    if (!loadMore && !forceRefresh && _isFetchedOnceForSchool) return;

    _isLoadingSchoolAll = true;
    try {
      if (loadMore) {
        if (_schoolCurrentPage >= _schoolTotalPages) {
          _isLoading = false;
          return;
        }
        _currentPage++;
      } else {
        _currentPage = 1;
        _schoolAchievementsAll.clear();
        _isFetchedOnceForSchool = false;
      }
      final response = await AchievementService().fetchSchoolAchievements(
        pageNo: _schoolCurrentPage,
        limit: 10,
        forStaff: forStaff,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        _schoolTotalPages = data['totalPages'];
        _schoolCurrentPage = data['currentPage'];

        final fetched =
            (data['achievements'] as List)
                .map((e) => AchievementModel.fromJson(e))
                .toList();

        _schoolAchievementsAll.addAll(fetched);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingSchoolAll = false;
      notifyListeners();
    }
  }

  // Separate pagination states for preview and full list
  // int _schoolPagePreview = 1;
  // int _schoolTotalPagesPreview = 1;

  // int _schoolPageAll = 1;
  // int _schoolTotalPagesAll = 1;

  // bool _isLoadingSchool = false;
  // bool get isLoadingSchool => _isLoadingSchool;
  // bool get hasMoreSchool => _schoolPageAll < _schoolTotalPagesAll;

  // Future<void> fetchSchoolAchievements({
  //   required bool forStaff,
  //   bool loadMore = false,
  //   bool forceRefresh = false,
  //   int limit = 3,
  // }) async {
  //   if (_isLoadingSchool) return;
  //   _isLoadingSchool = true;
  //   notifyListeners();

  //   try {
  //     // Decide which list and pagination to use based on limit
  //     final isPreview = limit == 3;

  //     if (!loadMore || forceRefresh) {
  //       if (isPreview) {
  //         _schoolPagePreview = 1;
  //         _schoolAchievements.clear();
  //       } else {
  //         _schoolPageAll = 1;
  //         _schoolAchievementsAll.clear();
  //       }
  //     }

  //     final pageNo = isPreview ? _schoolPagePreview : _schoolPageAll;

  //     final response = await AchievementService().fetchSchoolAchievements(
  //       pageNo: pageNo,
  //       limit: limit,
  //       forStaff: forStaff,
  //     );

  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       final fetched =
  //           (data['achievements'] as List)
  //               .map((e) => AchievementModel.fromJson(e))
  //               .toList();

  //       if (isPreview) {
  //         _schoolTotalPagesPreview = data['totalPages'] ?? 1;
  //         _schoolPagePreview = data['currentPage'] ?? 1;
  //         _schoolAchievements.addAll(fetched);

  //         if (_schoolPagePreview < _schoolTotalPagesPreview) {
  //           _schoolPagePreview++;
  //         }
  //       } else {
  //         _schoolTotalPagesAll = data['totalPages'] ?? 1;
  //         _schoolPageAll = data['currentPage'] ?? 1;
  //         _schoolAchievementsAll.addAll(fetched);

  //         if (_schoolPageAll < _schoolTotalPagesAll) {
  //           _schoolPageAll++;
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     _error = e.toString();
  //     log("Error fetching school achievements: $_error");
  //   } finally {
  //     _isLoadingSchool = false;
  //     notifyListeners();
  //   }
  // }

  // ===========================================================================
  // SINGLE ACHIEVEMENT
  // ===========================================================================
  Future<void> fetchSingleAchievement({
    required int achievementId,
    required bool forStaff,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AchievementService().fetchSingleAchievement(
        forStaff: forStaff,
        achievementId: achievementId,
      );

      if (response.statusCode == 200) {
        singleAchievement = AchievementModel.fromJson(response.data);
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching single achievement: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // CREATE / EDIT / DELETE
  // ===========================================================================
  Future<bool> createAchievement({
    required BuildContext context,
    required String title,
    required String description,
    required String category,
    required String level,
    required String date,
    required String awardingBody,
    required List<Map<String, dynamic>> students,
  }) async {
    _isLoadingSecondary = true;
    notifyListeners();

    try {
      final response = await AchievementService().createAchievement(
        context: context,
        title: title,
        description: description,
        category: category,
        level: level,
        date: date,
        awardingBody: awardingBody,
        students: students,
      );

      final code = response.statusCode ?? 0;
      if (code == 200 || code == 201) {
        await fetchAchievementsAddedByTeacher(forceRefresh: true);
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: "Achievement added successfully",
            type: SnackbarType.success,
          );
          Navigator.pop(context);
        }
        return true;
      }

      if (code == 400 || code == 422) {
        final msg = response.data?['message'] ?? 'Invalid data';
        if (context.mounted) CustomErrorDialog.show(context, msg);
        return false;
      }

      return false;
    } catch (e) {
      log("Error creating achievement: $e");
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: "Failed to create achievement: $e",
          type: SnackbarType.failure,
        );
      }
      return false;
    } finally {
      _isLoadingSecondary = false;
      notifyListeners();
    }
  }

  Future<void> editAchievement({
    required BuildContext context,
    required int achievementId,
    required String title,
    required String description,
  }) async {
    _isLoadingSecondary = true;
    notifyListeners();

    try {
      final response = await AchievementService().editAchievement(
        achievementId: achievementId,
        title: title,
        description: description,
      );

      if (response.statusCode == 200) {
        await fetchSingleAchievement(
          achievementId: achievementId,
          forStaff: true,
        );
        await fetchAchievementsAddedByTeacher(forceRefresh: true);
        if (context.mounted) {
          Navigator.pop(context);
          CustomSnackbar.show(
            context,
            message: "Achievement updated successfully",
            type: SnackbarType.success,
          );
        }
      } else if (response.statusCode == 400 && context.mounted) {
        CustomSnackbar.show(
          context,
          message: "${response.data['error']} — can't update",
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log("Error editing achievement: $e");
    } finally {
      _isLoadingSecondary = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAchievement(int id) async {
    try {
      final response = await AchievementService().deleteAchievement(
        achievementId: id,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        _teacherAchievements.removeWhere((a) => a.id == id);
        _studentAchievements.removeWhere((a) => a.id == id);
        // _schoolAchievements.removeWhere((a) => a.id == id);
        notifyListeners();
        return true;
      } else {
        log("Failed to delete achievement: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      log("Error deleting achievement: $e");
      return false;
    }
  }

  //for the school achievements
  Future<void> fetchAchievementSchool({
    required bool forStaff,
    bool loadMore = false,
    bool forceRefresh = false,
    int limit = AppConstants.paginationLimit,
  }) async {
    if (_isLoading) return;

    if (!loadMore || forceRefresh) {
      _currentPage = 1;
      _schoolAchievementsAll.clear();
    }
    if (!forceRefresh && !loadMore && _currentPage > _totalPages) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await AchievementService().fetchSchoolAchievements(
        forStaff: forStaff,
        pageNo: _currentPage,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Only update totalPages from server — never preset it!
        _totalPages = data['totalPages'] ?? 1;

        final List fetched = data['achievements'] ?? [];
        final achievements =
            fetched
                .map<AchievementModel>((e) => AchievementModel.fromJson(e))
                .toList();

        _schoolAchievementsAll.addAll(achievements);

        // Only increment page if we got data and there might be more
        if (achievements.isNotEmpty) {
          _currentPage++;
        }
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching school achievements: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // CLEAR FUNCTIONS
  // ===========================================================================
  void clearAll() {
    _teacherAchievements.clear();
    _studentAchievements.clear();
    // _schoolAchievements.clear();
    singleAchievement = null;
    notifyListeners();
  }
}
