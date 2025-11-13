import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class AchievementService {
  // Create achievement
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

  // Fetch achievement by student Id
  Future<Response> fetchAchievementsByStudentId({
    required studentId,
    required bool forStaff,
    required int pageNo,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? '${ApiEndpoints.achievementByStudentId}/$studentId?pageNo=$pageNo&limit=${AppConstants.paginationLimit}'
          : '${ApiEndpoints.achievementByGuardian}/$studentId?pageNo=$pageNo&limit=${AppConstants.paginationLimit}',
    );
    return response;
  }

  //fetching achievements added by teacher
  Future<Response> fetchAchievementsAddedByTeacher({
    required int pageNo,
  }) async {
    final response = await ApiServices.get(
      '${ApiEndpoints.getAllAchievement}?page=$pageNo&limit=${AppConstants.paginationLimit}',
    );
    return response;
  }

  // fetch single achievement
  Future<Response> fetchSingleAchievement({
    required bool forStaff,
    required int achievementId,
  }) async {
    final response = await ApiServices.get(
      "${forStaff ? ApiEndpoints.singleAchievementForStaff : ApiEndpoints.singleAchievementForGuardian}/$achievementId",
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

  //fetch achievements for public
  Future<Response> fetchSchoolAchievements({
    required int pageNo,
    required int limit,
    required bool forStaff,
  }) async {
    final response = await ApiServices.get(
      forStaff
          ? '${ApiEndpoints.getAchievementsBySchoolStaff}?page=$pageNo&limit=$limit'
          : '${ApiEndpoints.getAchievementsBySchoolGuardian}?page=$pageNo&limit=$limit',
    );
    return response;
  }
}
