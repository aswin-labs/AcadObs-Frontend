import 'dart:developer';
import 'dart:io';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/profile/data/models/guardian_model.dart';
import 'package:acadobs/features/profile/data/services/profile_services.dart';
import 'package:acadobs/features/teacher/data/models/staff_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  bool _isPhotoLoading = false;
  bool get isPhotoLoading => _isPhotoLoading;

  GuardianModel? guardianProfile;
  StaffModelProfile? staffProfile;
  bool _editProfileEnabled = false;
  bool get editProfileEnabled => _editProfileEnabled;

  List<String> _guardianRelations = [];
  List<String> get guardianRelations => _guardianRelations;

  bool _isLoadingRelations = false;
  bool get isLoadingRelations => _isLoadingRelations;

  static const List<String> defaultRelations = [
    "father",
    "mother",
    "grandfather",
    "grandmother",
    "uncle",
    "aunty",
    "local_guardian",
    "other",
  ];

  /// Helper to extract clean error message from DioException or general Exception
  String _extractErrorMessage(dynamic e, String defaultMessage) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        if (data['message'] != null &&
            data['message'].toString().trim().isNotEmpty) {
          return data['message'].toString().trim();
        }
        if (data['error'] != null &&
            data['error'].toString().trim().isNotEmpty) {
          return data['error'].toString().trim();
        }
        if (data['detail'] != null &&
            data['detail'].toString().trim().isNotEmpty) {
          return data['detail'].toString().trim();
        }
      } else if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'Connection timed out. Please check your internet connection.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Unable to connect to the server. Please check your internet connection.';
      }
      if (e.response?.statusCode != null) {
        return 'Request failed with status code ${e.response?.statusCode}';
      }
    }
    return defaultMessage;
  }

  // Change password
  Future<bool> changePassword({
    required BuildContext context,
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
        log("Password changed successfully: ${response.data}");
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: "Password changed successfully",
            type: SnackbarType.success,
          );
        }
        return true;
      } else {
        log("Failed to change password: ${response.data}");
        final errorMsg = response.data is Map
            ? (response.data['message'] ??
                response.data['error'] ??
                "Failed to change password")
            : "Failed to change password";
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: errorMsg.toString(),
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      log("Error changing password: $e");
      final errorMsg = _extractErrorMessage(
        e,
        "Failed to change password. Please check your current password.",
      );
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: errorMsg,
          type: SnackbarType.failure,
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch profile details
  Future<void> fetchProfileGuardian() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ProfileServices().fetchProfileDetails();
      log("Fetched guardian profile response: ${response.data}");
      if (response.statusCode == 200 && response.data['guardian'] != null) {
        guardianProfile = GuardianModel.fromJson({
          ...Map<String, dynamic>.from(response.data['guardian']),
          'user': Map<String, dynamic>.from(response.data['user']),
        });

        log(guardianProfile.toString());
      } else {
        log("Guardian data missing in response");
        guardianProfile = null;
      }
      notifyListeners();
    } catch (e, st) {
      log('Error fetching guardian profile: $e');
      log('Stack trace: $st');
      guardianProfile = null;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch guardian relations
  Future<void> fetchGuardianRelations() async {
    _isLoadingRelations = true;
    notifyListeners();
    try {
      final response = await ProfileServices().getGuardianRelations();
      log("Fetched guardian relations response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        List rawList = [];
        if (response.data is List) {
          rawList = response.data as List;
        } else if (response.data is Map) {
          final map = response.data as Map;
          if (map['data'] is List) {
            rawList = map['data'] as List;
          } else if (map['relations'] is List) {
            rawList = map['relations'] as List;
          }
        }
        _guardianRelations = rawList.map((e) => e.toString()).toList();
        if (_guardianRelations.isEmpty) {
          _guardianRelations = List.from(defaultRelations);
        }
      } else if (_guardianRelations.isEmpty) {
        _guardianRelations = List.from(defaultRelations);
      }
    } catch (e) {
      log("Error fetching guardian relations: $e");
      if (_guardianRelations.isEmpty) {
        _guardianRelations = List.from(defaultRelations);
      }
    } finally {
      _isLoadingRelations = false;
      notifyListeners();
    }
  }

  // Enable edit profile
  void enableEditProfile() {
    _editProfileEnabled = true;
    notifyListeners();
  }

  // Disable edit profile
  void disableEditProfile() {
    _editProfileEnabled = false;
    notifyListeners();
  }

  // Save profile details
  Future<bool> saveProfileDetails({
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
        await fetchProfileGuardian();
        disableEditProfile();
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: 'Profile updated successfully',
            type: SnackbarType.success,
          );
        }
        return true;
      } else {
        log('Failed to update profile: ${response.statusCode}');
        final errorMsg = response.data is Map
            ? (response.data['message'] ??
                response.data['error'] ??
                'Failed to update profile')
            : 'Failed to update profile';
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: errorMsg.toString(),
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      log('Error saving profile details: $e');
      final errorMsg = _extractErrorMessage(
        e,
        'Failed to update profile. Please check your input and try again.',
      );
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: errorMsg,
          type: SnackbarType.failure,
        );
      }
      return false;
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Update credentials and name
  Future<bool> changeCredentialAndName({
    required BuildContext context,
    required GuardianModel guardian,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final response = await ProfileServices().changeCredentialAndName(
        guardian: guardian,
      );
      if (response.statusCode == 200) {
        log('Login credentials updated successfully');
        await fetchProfileGuardian();
        disableEditProfile();
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: 'Login credentials updated successfully',
            type: SnackbarType.success,
          );
        }
        return true;
      } else {
        log('Failed to update credentials: ${response.statusCode}');
        final errorMsg = response.data is Map
            ? (response.data['message'] ??
                response.data['error'] ??
                'Failed to update login credentials')
            : 'Failed to update login credentials';
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: errorMsg.toString(),
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      log('Error changing credentials: $e');
      final errorMsg = _extractErrorMessage(
        e,
        'Failed to update login credentials. The email or phone may already be registered.',
      );
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: errorMsg,
          type: SnackbarType.failure,
        );
      }
      return false;
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Update profile photo
  Future<bool> updateProfilePhoto({
    required BuildContext context,
    required File imageFile,
    required bool forStaff,
  }) async {
    _isPhotoLoading = true;
    notifyListeners();
    log("Starting profile photo upload...");

    try {
      final response = await ProfileServices().updateProfilePhoto(
        forStaff: forStaff,
        imageFile: imageFile,
      );
      log("🟢 Upload response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        log("Profile photo updated successfully, fetching updated profile...");
        forStaff ? await fetchProfileStaff() : await fetchProfileGuardian();
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: 'Profile photo updated successfully!',
            type: SnackbarType.success,
          );
        }
        return true;
      } else {
        log("Failed to update profile photo: ${response.statusCode}");
        final errorMsg = response.data is Map
            ? (response.data['message'] ??
                response.data['error'] ??
                "Failed to update profile photo")
            : "Failed to update profile photo";
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: errorMsg.toString(),
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e, st) {
      log("Error updating profile photo: $e");
      log("Stack trace: $st");
      final errorMsg = _extractErrorMessage(
        e,
        "Failed to upload profile photo. Please try again.",
      );
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: errorMsg,
          type: SnackbarType.failure,
        );
      }
      return false;
    } finally {
      _isPhotoLoading = false;
      notifyListeners();
      log("Done updating profile photo");
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
        log("Staff data missing in response");
        staffProfile = null;
      }
      notifyListeners();
    } catch (e, st) {
      log('Error fetching staff profile: $e');
      log('Stack trace: $st');
      staffProfile = null;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save profile details staff
  Future<bool> saveProfileDetailsStaff({
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
        log('Staff profile updated successfully');
        await fetchProfileStaff();
        disableEditProfile();
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: 'Profile updated successfully',
            type: SnackbarType.success,
          );
        }
        return true;
      } else {
        log('Failed to update staff profile: ${response.statusCode}');
        final errorMsg = response.data is Map
            ? (response.data['message'] ??
                response.data['error'] ??
                'Failed to update profile')
            : 'Failed to update profile';
        if (context.mounted) {
          CustomSnackbar.show(
            context,
            message: errorMsg.toString(),
            type: SnackbarType.failure,
          );
        }
        return false;
      }
    } catch (e) {
      log('Error updating staff profile: $e');
      final errorMsg = _extractErrorMessage(
        e,
        'Failed to update profile. Please try again.',
      );
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: errorMsg,
          type: SnackbarType.failure,
        );
      }
      return false;
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }
}
