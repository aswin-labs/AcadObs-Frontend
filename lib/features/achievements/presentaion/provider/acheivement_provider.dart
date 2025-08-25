import 'dart:developer';
import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/achievements/data/services/achievement_service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class AchievementProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

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
}
