// lib/providers/login_provider.dart
import 'dart:developer';
import 'dart:io';

import 'package:acadobs/core/services/api_services.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/popup_loader.dart';
import 'package:acadobs/features/authentication/data/models/parent_school_model.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/data/services/auth_services.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/teacher_attendance_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/user_permission_model.dart';
import 'package:dio/dio.dart';
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

  /// Extract human-readable error messages from various exceptions and response bodies
  String _parseErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timed out. Please check your internet connection.";
        case DioExceptionType.connectionError:
          return "Unable to connect to server. Please check your internet connection.";
        case DioExceptionType.badResponse:
          final response = error.response;
          if (response?.data != null) {
            final data = response!.data;
            if (data is Map) {
              if (data['message'] != null &&
                  data['message'].toString().trim().isNotEmpty) {
                return data['message'].toString().trim();
              }
              if (data['error'] != null &&
                  data['error'].toString().trim().isNotEmpty) {
                return data['error'].toString().trim();
              }
              if (data['msg'] != null &&
                  data['msg'].toString().trim().isNotEmpty) {
                return data['msg'].toString().trim();
              }
              if (data['errors'] != null) {
                final errors = data['errors'];
                if (errors is List && errors.isNotEmpty) {
                  return errors.first.toString();
                } else if (errors is Map && errors.isNotEmpty) {
                  return errors.values.first.toString();
                }
              }
            } else if (data is String && data.trim().isNotEmpty) {
              return data.trim();
            }
          }
          final statusCode = response?.statusCode;
          if (statusCode == 400) {
            return "Invalid request. Please verify your phone number or username and password.";
          } else if (statusCode == 401) {
            return "Incorrect phone number/username or password. Please try again.";
          } else if (statusCode == 403) {
            return "Access denied. Your account may be inactive or restricted.";
          } else if (statusCode == 404) {
            return "Account not found. Please verify your entered details.";
          } else if (statusCode == 429) {
            return "Too many login attempts. Please wait a few moments and try again.";
          } else if (statusCode != null && statusCode >= 500) {
            return "Server is temporarily unavailable. Please try again later.";
          }
          return "Login failed (${statusCode ?? 'Unknown'}). Please try again.";
        case DioExceptionType.cancel:
          return "Login request was cancelled.";
        default:
          return "Network error occurred. Please check your internet connection.";
      }
    } else if (error is SocketException) {
      return "No internet connection detected. Please verify your network.";
    }
    return "Something went wrong. Please try again.";
  }

  // Login for all roles (Parents, Teachers, Staff)
  Future<bool> login({
    required BuildContext context,
    required String identifier,
    required String password,
  }) async {
    _setLoading(true);
    _loginError = null;

    try {
      final response = await AuthServices().login(
        identifier: identifier.trim(),
        password: password,
      );
      log("Login Response: ${response.data}");

      if (response.data == null || response.data is! Map) {
        _setError("Unexpected server response format. Please try again.");
        return false;
      }

      final data = Map<String, dynamic>.from(response.data);
      final token = data['token']?.toString();
      final userData = data['userData'];
      final refreshToken = data['refreshToken']?.toString();

      if (token == null || userData == null) {
        final serverMsg =
            data['message']?.toString() ??
            data['error']?.toString() ??
            "Invalid credentials. Please try again.";
        _setError(serverMsg);
        return false;
      }

      // Save token and user details in secure storage
      await _storageService.saveUserCredentials(
        token: token,
        userData: Map<String, dynamic>.from(userData),
      );

      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _storageService.saveTokens(
          accessToken: token,
          refreshToken: refreshToken,
        );
      }

      final userRole = await _storageService.getUserRole();
      log("Logged in user role: $userRole");

      // Reset session manager logout state on successful login
      try {
        ApiServices.sessionManager.reset();
      } catch (e) {
        log("SessionManager reset note: $e");
      }

      if (!context.mounted) return true;

      CustomSnackbar.show(
        context,
        message: "Login Successful",
        type: SnackbarType.success,
      );

      // Route based on user role
      if (userRole == 'guardian') {
        try {
          await fetchSchoolsByParent();
        } catch (e) {
          log("Error fetching schools for parent: $e");
        }

        try {
          await AuthServices().sendFcmToken();
        } catch (e) {
          log("FCM token sync skipped/failed: $e");
        }

        if (_totalSchoolsUnderParent == 1) {
          if (!context.mounted) return true;
          context.pushReplacementNamed(
            RouteConstants.bottomNavScreen,
            extra: UserType.parent,
          );
        } else {
          if (!context.mounted) return true;
          context.pushReplacementNamed(RouteConstants.schoolSelectionScreen);
        }
      } else if (userRole == 'teacher') {
        try {
          await fetchSchoolDetailsForTeacher();
        } catch (e) {
          log("Error fetching school details for teacher: $e");
        }

        if (!context.mounted) return true;
        context.pushReplacementNamed(
          RouteConstants.bottomNavScreen,
          extra: UserType.teacher,
        );
      } else if (userRole == 'staff') {
        try {
          await fetchSchoolDetailsForTeacher();
        } catch (e) {
          log("Error fetching school details for staff: $e");
        }

        try {
          await getStaffPermissions();
        } catch (e) {
          log("Error fetching staff permissions: $e");
        }

        if (!context.mounted) return true;
        context.pushReplacementNamed(
          RouteConstants.bottomNavScreen,
          extra: UserType.nonTeachingStaff,
        );
      } else {
        log("Unsupported user role: $userRole");
        _setError(
          "Account role '$userRole' is not authorized to access this mobile portal. Please contact your school administrator.",
        );
        await _storageService.clear();
        return false;
      }

      return true;
    } catch (e, stack) {
      log("Login exception: $e", stackTrace: stack);
      final errorMsg = _parseErrorMessage(e);
      _setError(errorMsg);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout

  Future<void> logout(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    if (context.mounted) {
      PopupLoader.show(context, message: "Logging out...");
    }

    await Future.delayed(const Duration(milliseconds: 100));

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
          context.goNamed(RouteConstants.loginScreen);
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
      if (context.mounted) {
        PopupLoader.hide(context);
      }

      _isLoading = false;
      notifyListeners();
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
    if (_selectedSchool?.schoolId != null) {
      await _storageService.saveSchoolIdForParent(
        schoolId: _selectedSchool!.schoolId.toString(),
      );
    }
  }

  // fetch school details for guardian by school id
  Future<void> fetchSchoolDetailsForGuardianBySchoolId() async {
    _isLoading = true;
    try {
      final schoolIdStr = await _storageService.getSchoolIdForParent();
      final schoolId = int.tryParse(schoolIdStr ?? '');
      if (schoolId != null) {
        final response = await AuthServices()
            .fetchSchoolDetailsForGuardianBySchoolId(schoolId: schoolId);
        if (response.statusCode == 200) {
          log("Guardian School Details Fetched Successfully: ${response.data}");
          final rawData = response.data;
          final schoolData =
              (rawData != null && rawData['school'] != null)
                  ? Map<String, dynamic>.from(rawData['school'])
                  : Map<String, dynamic>.from(rawData ?? {});
          _schoolDetails = schoolData;
          await _storageService.saveSchoolDetailsForParent(
            schoolData: _schoolDetails!,
          );
          notifyListeners();
        }
      }
    } catch (e) {
      log("Error in fetchSchoolDetailsForGuardianBySchoolId: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
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
