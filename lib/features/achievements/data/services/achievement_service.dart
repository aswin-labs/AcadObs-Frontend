import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AchievementService {
  Future<Response> createAchievement({
    required BuildContext context,
    required String title,
    required String description,
    required String category,
    required String level,
    required String date,
    required String awardingBody,
    required List<Map<String, dynamic>> students,
  }) async {
    final formData = {
      "title": title,
      "description": description,
      "category": category,
      "level": level,
      "date": date,
      "awarding_body": awardingBody,
      "students": students,
    };

    try {
      log("FormData sent: $formData");
      final response = await ApiServices.post(
        ApiEndpoints.createAcheivement,
        formData,
        isFormData: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> fetchAchievementByStudentId({
    required studentId,
    required bool forStaff,
    required int pageNo,
    required int limit,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? '${ApiEndpoints.achievementByStudentId}/$studentId?pageNo=$pageNo&limit=$limit'
          : '${ApiEndpoints.achievementByGuardian}/$studentId?pageNo=$pageNo&limit=$limit',
    );
    return response;
  }

  //fetching all the achievements
  Future<Response> fetchALlAchievement({
    // required int limit,
    required int pageNo,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.getAllAchievement}?page=$pageNo&limit=${AppConstants.paginationLimit}',
    );
    return response;
  }

  //edit achievement
  Future<Response> editAchievement({
    required int achievementId,
    required String title,
    required String description,
  }) async {
    final response = await ApiServices.put(
      "${ApiEndpoints.achievements}/$achievementId",
      {"title": title.trim(), "description": description.trim()}, 
      isFormData: true,
    );

    return response;
  }

  //delete achievements
  Future<Response> deleteAchievement({required int achievementId}) async {
    final response = await ApiServices.delete(
      "${ApiEndpoints.deleteAchievement}/$achievementId",
    );
    return response;
  }
}
