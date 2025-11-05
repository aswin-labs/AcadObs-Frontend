import 'dart:developer';
import 'dart:io';

import 'package:acadobs/core/utils/urls/api_end_points.dart';
import 'package:acadobs/features/profile/data/models/guardian_model.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/api_services.dart';

class ProfileServices {
  // Change Password
  Future<Response> changePassword({
    required String newPassword,
    required String oldPassword,
    required bool forStaff,
  }) async {
    final response = await ApiServices.put(
      forStaff
          ? ApiEndpoints.staffChangePassword
          : ApiEndpoints.guardianChangePassword,
      {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
    return response;
  }

  // Fetch profile details
  Future<Response> fetchProfileDetails() async {
    final response = await ApiServices.get(ApiEndpoints.guardianProfile);
    return response;
  }

  // update profile details
  Future<Response> updateProfileDetails({
    required GuardianModel guardian,
  }) async {
    final response = await ApiServices.put(ApiEndpoints.updateGuardianProfile, {
      "guardian_name": guardian.guardianName,
      "guardian_contact": guardian.guardianContact,
      "guardian_email": guardian.guardianEmail,
      "guardian_job": guardian.guardianJob,
      "guardian_relation": guardian.guardianRelation,
      "guardian2_name": guardian.guardian2Name,
      "guardian2_contact": guardian.guardian2Contact,
      "guardian2_job": guardian.guardian2Job,
      "guardian2_relation": guardian.guardian2Relation,
      "father_name": guardian.fatherName,
      "mother_name": guardian.motherName,
    });

    return response;
  }

  // update profile photo
  Future<Response> updateProfilePhoto({
    required File imageFile,
    required bool forStaff,
  }) async {
    log('🟡 Uploading profile photo...');
    log('📁 File path: ${imageFile.path}');
    log('📦 File exists: ${await imageFile.exists()}');
    log('🌐 Endpoint: ${ApiEndpoints.updateProfilePhotoGuardian}');
    final formData = {'dp': await MultipartFile.fromFile(imageFile.path)};

    try {
      final response = await ApiServices.put(
        forStaff
            ? ApiEndpoints.updateProfilePhotoGuardian
            : ApiEndpoints.updateProfilePhotoGuardian,
        formData,
        isFormData: true,
      );

      log('🟢 Upload response status: ${response.statusCode}');
      log('🧾 Response data: ${response.data}');
      return response;
    } catch (e) {
      log('🔴 Failed to update profile photo: $e');
      rethrow;
    }

  }
}
