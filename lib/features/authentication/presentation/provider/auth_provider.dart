// lib/providers/login_provider.dart
import 'dart:developer';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/authentication/data/models/parent_school_model.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/data/services/auth_services.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/user_permission_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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

  String? _schoolName;
  String? get schoolName => _schoolName;

  String? _logo;
  String? get logo => _logo;

  String? _schoolImage;
  String? get schoolImage => _schoolImage;

  // call this at the start of login
  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // call this when login succeeds
  void _clearError() {
    _loginError = null;
    notifyListeners();
  }

  // call this when login fails
  void _setError(String msg) {
    _loginError = msg;
    notifyListeners();
  }

  void clearLoginError() => _clearError();

  // Login

  Future<void> login({
    required BuildContext context,
    required String identifier,
    required String password,
  }) async {
    // _isLoading = true;
    _setLoading(true);
    _clearError();
    notifyListeners();

    try {
      final response = await AuthServices().login(
        identifier: identifier,
        password: password,
      );
      await _storageService.saveUserCredentials(
        token: response.data['token'],
        // refreshToken: response.data['refreshToken'],
        userData: response.data['userData'],
      );

      await _storageService.saveTokens(
        accessToken: response.data['token'],
        refreshToken: response.data['refreshToken'],
      );

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
            context.goNamed(RouteConstants.schoolSelectionScreen);
          }
        } else if (userRole == 'teacher') {
          await fetchSchoolDetailsForTeacher();
          if (!context.mounted) return;
          context.goNamed(
            RouteConstants.bottomNavScreen,
            extra: UserType.teacher,
          );
        } else if (userRole == 'admin') {
          context.goNamed(
            RouteConstants.bottomNavScreen,
            extra: UserType.schoolAdmin,
          );
        } else {
          context.goNamed(
            RouteConstants.bottomNavScreen,
            extra: UserType.superAdmin,
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
    await _storageService.clear();
    if (!context.mounted) return;
    CustomSnackbar.show(
      context,
      message: "Logout successfull",
      type: SnackbarType.success,
    );
    context.goNamed(RouteConstants.loginScreen);
    notifyListeners();
  }

  // Schools by guardian
  Future<void> fetchSchoolsByParent() async {
    _isLoading = true;
    _schools.clear();
    try {
      final response = await AuthServices().fetchSchoolsByParent();
      if (response.statusCode == 200) {
        final data = response.data;
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
    // _selectedSchool = school;
    // log("Selected schoolId: ${_selectedSchool?.schoolId}");
    // notifyListeners();
  }

  /// Save schoolId in secure storage
  Future<void> saveSchoolIdAndContinue() async {
    if (_selectedSchool?.schoolId != null &&
        _selectedSchool?.school?.name != null) {
      await _storageService.saveSchoolIdForParent(
        schoolId: _selectedSchool!.schoolId.toString(),
      );
      await _storageService.saveSchoolNameForParent(
        schoolName: _selectedSchool!.school!.name!,
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
        final data = response.data;
        log(data.toString());
        await _storageService.saveSchoolDetailsForTeacher(
          schoolData: data['school'],
        );
        _schoolName = data['school']['name'];
        _logo = data['school']['logo'];
        _schoolImage = data['school']['image'];
        notifyListeners();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
}
