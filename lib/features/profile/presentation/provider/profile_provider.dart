import 'dart:developer';
import 'dart:io';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/profile/data/models/guardian_model.dart';
import 'package:acadobs/features/profile/data/services/profile_services.dart';
import 'package:acadobs/features/teacher/data/models/staff_model.dart';

import 'package:flutter/cupertino.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;
  GuardianModel? guardianProfile;
  StaffModelProfile? staffProfile;
  bool _editProfileEnabled = false;
  bool get editProfileEnabled => _editProfileEnabled;
  //change password
  Future<void> changePassword({
    required String newPassword,
    required String oldPassword,
    required bool forStaff,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ProfileServices().changePassword(
        newPassword: newPassword,
        oldPassword: oldPassword,
        forStaff: forStaff,
      );
      if (response.statusCode == 200) {
        log("password changed successfully: ${response.data}");
      } else {
        log("failed to change the password: ${response.data}");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch profile details
  Future<void> fetchProfileDetails() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ProfileServices().fetchProfileDetails();
      log(" Fetched guardian profile response: ${response.data}");
      if (response.statusCode == 200 && response.data['guardian'] != null) {
        guardianProfile = GuardianModel.fromJson(
          Map<String, dynamic>.from(response.data['guardian']),
        );
      } else {
        log(" Guardian data missing in response");
        guardianProfile = null;
      }
      notifyListeners();
    } catch (e, st) {
      log('Error fetching guardian profile: $e');
      log('Error fetching guardian profile: $e');
      log('Stack trace: $st');
      guardianProfile = null;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enable edit profile
  void enableEditProfile() {
    _editProfileEnabled = true;
    notifyListeners();
  }

  // disable edit profile
  void disableEditProfile() {
    _editProfileEnabled = false;
    notifyListeners();
  }

  // save profile details
  Future<void> saveProfileDetails({
    required BuildContext context,
    required GuardianModel guardian,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await ProfileServices().updateProfileDetails(
        guardian: guardian,
      );
      if (response.statusCode == 200) {
        log('Profile updated successfully');
        disableEditProfile();
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: 'Profile updated successfully',
          type: SnackbarType.success,
        );
      } else {
        log('Failed to update profile: ${response.statusCode}');
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: 'Failed to update profile',
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log('Error: $e');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // update profile photo
  Future<void> updateProfilePhoto(File imageFile) async {
    _isLoading = true;
    notifyListeners();
    log(" Starting profile photo upload...");

    try {
      final response = await ProfileServices().updateProfilePhoto(imageFile);
      log(" Upload response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        log("Profile photo updated successfully, fetching updated profile...");
        log(" Profile photo updated successfully");
        await fetchProfileDetails();
      } else {
        log(" Failed to update profile photo: ${response.statusCode}");
      }
    } catch (e, st) {
      log("Error updating profile photo: $e");
      log("Stack trace: $st");
    } finally {
      _isLoading = false;
      notifyListeners();
      log(" Done updating profile photo");
    }
  }

  // Fetch profile details for staff
  Future<void> fetchProfileStaff() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ProfileServices().fetchProfileStaff();
      log("Fetched staff profile response: ${response.data}");
      if (response.statusCode == 200 && response.data['staff'] != null) {
        final staffData = Map<String, dynamic>.from(response.data['staff']);
        staffData['user'] = response.data['user'];

        staffProfile = StaffModelProfile.fromJson(staffData);
      } else {
        log("staff data missing in response");
        staffProfile = null;
      }
      notifyListeners();
    } catch (e, st) {
      log('Error fetching staff profile: $e');
      log(' Error fetching staff profile: $e');
      log('Stack trace: $st');
      staffProfile = null;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // save profile details staff
  Future<void> saveProfileDetailsStaff({
    required BuildContext context,
    required StaffModelProfile staff,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await ProfileServices().updateProfileDetailsStaff(
        staff: staff,
      );
      if (response.statusCode == 200) {
        log('Profile updated successfully');
        disableEditProfile();
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: 'Profile updated successfully',
          type: SnackbarType.success,
        );
      } else {
        log('Failed to update profile: ${response.statusCode}');
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: 'Failed to update profile',
          type: SnackbarType.failure,
        );
      }
    } catch (e) {
      log('Error: $e');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }
}
