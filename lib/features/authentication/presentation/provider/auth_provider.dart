// lib/providers/login_provider.dart
import 'dart:developer';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/authentication/data/models/parent_school_model.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/data/services/auth_services.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthProvider with ChangeNotifier {
  final AuthStorageService _storageService = AuthStorageService();

  bool _isLoading = false;
  List<SchoolModel> _schools = [];
  int _totalSchoolsUnderParent = 0;

  SchoolModel? _selectedSchool; // store selected school

  bool get isLoading => _isLoading;
  List<SchoolModel> get schools => _schools;
  int get totalSchoolsUnderParent => _totalSchoolsUnderParent;
  SchoolModel? get selectedSchool => _selectedSchool;

  // Login

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthServices().login(
        email: email,
        password: password,
      );
      await _storageService.saveUserCredentials(
        token: response.data['token'],
        userData: response.data['userData'],
      );

      if (response.statusCode == 200) {
        final userRole = await _storageService.getUserRole();
        if (!context.mounted) return;
        if (userRole == 'guardian') {
          context.pushNamed(RouteConstants.schoolSelectionScreen);
        } else if (userRole == 'teacher') {
          await fetchSchoolDetailsForTeacher();
          if (!context.mounted) return;
          context.pushNamed(
            RouteConstants.bottomNavScreen,
            extra: UserType.teacher,
          );
        } else if (userRole == 'admin') {
          context.pushNamed(
            RouteConstants.bottomNavScreen,
            extra: UserType.schoolAdmin,
          );
        } else {
          context.pushNamed(
            RouteConstants.bottomNavScreen,
            extra: UserType.superAdmin,
          );
        }
      }
    } catch (e) {
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
    _selectedSchool = school;
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
        await _storageService.saveSchoolDetailsForTeacher(
          schoolData: data['school'],
        );
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
