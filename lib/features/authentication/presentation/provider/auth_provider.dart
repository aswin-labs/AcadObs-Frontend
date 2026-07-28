// lib/providers/login_provider.dart
import 'dart:developer';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/authentication/data/models/parent_school_model.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/data/services/auth_services.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/teacher_attendance_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/user_permission_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthStorageService _storageService = AuthStorageService();

  bool _isLoading = false;
  List<SchoolModel> _schools = [];
  int _totalSchoolsUnderParent = 0;
  String? _loginError;

  SchoolModel? _selectedSchool; // store selected school

  bool get isLoading => _isLoading;
  List<SchoolModel> get schools => _schools;
  int get totalSchoolsUnderParent => _totalSchoolsUnderParent;
  SchoolModel? get selectedSchool => _selectedSchool;
  String? get loginError => _loginError;

  Map<String, dynamic>? _schoolDetails;

  Map<String, dynamic>? get schoolDetails => _schoolDetails;

  // call this at the start of login
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // call this when login fails
  void _setError(String msg) {
    _loginError = msg;
    notifyListeners();
  }

  void clearLoginError() {
    if (_loginError == null) return;

    _loginError = null;
    notifyListeners();
  }

  // Login

  Future<void> login({
    required BuildContext context,
    required String identifier,
    required String password,
  }) async {
    // _isLoading = true;
    _setLoading(true);
    _loginError = null;
    notifyListeners();

    try {
      final response = await AuthServices().login(
        identifier: identifier,
        password: password,
      );
      log("Login Response: ${response.data}");
      await _storageService.saveUserCredentials(
        token: response.data['token'],
        userData: response.data['userData'],
      );

      await _storageService.saveTokens(
        accessToken: response.data['token'],
        refreshToken: response.data['refreshToken'],
      );
      log(">>>status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final userRole = await _storageService.getUserRole();
        if (!context.mounted) return;
        CustomSnackbar.show(
          context,
          message: "Login Successfull",
          type: SnackbarType.success,
        );

        if (userRole == 'guardian') {
          await fetchSchoolsByParent();
          await AuthServices().sendFcmToken();
          if (_totalSchoolsUnderParent == 1) {
            if (!context.mounted) return;
            context.pushReplacementNamed(
              RouteConstants.bottomNavScreen,
              extra: UserType.parent,
            );
          } else {
            if (!context.mounted) return;
            context.pushReplacementNamed(RouteConstants.schoolSelectionScreen);
          }
        } else if (userRole == 'teacher') {
          await fetchSchoolDetailsForTeacher();
          if (!context.mounted) return;
          context.pushReplacementNamed(
            RouteConstants.bottomNavScreen,
            extra: UserType.teacher,
          );
        }
        return;
      }
      final serverMsg =
          response.data['message']?.toString() ??
          response.data['error']?.toString() ??
          "Invalid credentials";
      _setError(serverMsg);
    } catch (e) {
      // debugPrint("Login error: $e");
      _setError("Something went wrong. Please try again.");
      debugPrint("Login error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout

  Future<void> logout(BuildContext context) async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      log("Logging out with refresh token: $refreshToken");
      if (refreshToken != null) {
        final response = await AuthServices().logout(
          refreshToken: refreshToken,
        );
        log("Logout Response: ${response.data}");
        if (response.statusCode == 200) {
          log("Logout successful");
          if (!context.mounted) return;
          CustomSnackbar.show(
            context,
            message: "Logout successful",
            type: SnackbarType.success,
          );
          context.read<TeacherAttendanceProvider>().resetAttendance();
          context.pushReplacementNamed(RouteConstants.loginScreen);
          notifyListeners();
        } else {
          if (!context.mounted) return;
          CustomSnackbar.show(
            context,
            message: "Logout failed. Please try again later.",
            type: SnackbarType.failure,
          );
          log("Logout failed with status code: ${response.statusCode}");
        }
      }
    } catch (e) {
      log("Logout error: $e");
    } finally {
      await clearSession();
    }
  }

  // Schools by guardian
  Future<void> fetchSchoolsByParent() async {
    _isLoading = true;
    _schools.clear();
    try {
      final response = await AuthServices().fetchSchoolsByParent();
      if (response.statusCode == 200) {
        final data = response.data;
        log("Schools under parent: $data");
        _totalSchoolsUnderParent = data['totalcontent'];

        _schools =
            (data['schools'] as List<dynamic>)
                .map((json) => SchoolModel.fromJson(json))
                .toList();
        if (_totalSchoolsUnderParent == 1) {
          _selectedSchool = _schools[0];
          saveSchoolIdAndContinue();
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Select a school and store globally
  void selectSchool(SchoolModel school) {
    if (_selectedSchool?.schoolId == school.schoolId) {
      _selectedSchool = null;
    } else {
      _selectedSchool = school;
    }
    log("Selected schoolId: ${_selectedSchool?.schoolId}");
    notifyListeners();
  }

  /// Save schoolId in secure storage
  Future<void> saveSchoolIdAndContinue() async {
    if (_selectedSchool?.schoolId != null &&
        _selectedSchool?.school?.name != null) {
      await _storageService.saveSchoolIdForParent(
        schoolId: _selectedSchool!.schoolId.toString(),
      );
      await _storageService.saveSchoolDetailsForParent(
        schoolData: {
          "id": _selectedSchool!.school?.id,
          "name": _selectedSchool!.school?.name,
          "address": _selectedSchool!.school?.address,
          "phone": _selectedSchool!.school?.phone,
          "email": _selectedSchool!.school?.email,
          "logo": _selectedSchool!.school?.logo,
          "bg_image": _selectedSchool!.school?.bgImage,
        },
      );
    }
  }

  // fetch school details for teacher
  Future<void> fetchSchoolDetailsForTeacher() async {
    _isLoading = true;
    try {
      final response = await AuthServices().fetchSchoolDetailsForTeacher();
      if (response.statusCode == 200) {
        log("School Details Fetched Successfully");
        final data = Map<String, dynamic>.from(response.data);
        _schoolDetails = Map<String, dynamic>.from(data);
        await _storageService.saveSchoolDetailsForTeacher(
          schoolData: _schoolDetails!,
        );
        notifyListeners();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //  load school details for teacher
  Future<void> loadSchoolDetailsForTeacher() async {
    try {
      final storedData = await _storageService.getSchoolDetailsForTeacher();

      _schoolDetails =
          storedData == null ? null : Map<String, dynamic>.from(storedData);
    } catch (e) {
      log("Failed to load stored school details: $e");
      _schoolDetails = null;
    }

    notifyListeners();
  }

  // retrieve and save staff permissions
  UserPermissionModel? staffPermission;
  Future<void> getStaffPermissions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First try to load from local storage
      final storedPermission = await AuthStorageService().getUserPermissions();

      if (storedPermission != null) {
        staffPermission = storedPermission;
        notifyListeners();
      }

      // Always fetch fresh permissions from API
      final response = await AuthServices().getStaffPermissions();

      if (response.statusCode == 200) {
        staffPermission = UserPermissionModel.fromJson(response.data);

        // Save locally
        await AuthStorageService().saveUserPermissions(
          permissions: staffPermission!,
        );
      }
    } catch (e) {
      log("Permission Fetch Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // clear session data on logout
  Future<void> clearSession() async {
    await _storageService.clear();
    notifyListeners();
  }
}
