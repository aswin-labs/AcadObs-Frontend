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

  // Forgot Password State
  bool _isForgotPasswordLoading = false;
  String? _forgotPasswordError;
  String? _resetToken;
  String? _forgotPasswordPhone;

  bool get isForgotPasswordLoading => _isForgotPasswordLoading;
  String? get forgotPasswordError => _forgotPasswordError;
  String? get resetToken => _resetToken;
  String? get forgotPasswordPhone => _forgotPasswordPhone;

  void clearForgotPasswordError() {
    if (_forgotPasswordError == null) return;
    _forgotPasswordError = null;
    notifyListeners();
  }

  void resetForgotPasswordState() {
    _isForgotPasswordLoading = false;
    _forgotPasswordError = null;
    _resetToken = null;
    _forgotPasswordPhone = null;
    notifyListeners();
  }

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

  /// Checks whether a string looks like a developer/console error, stack trace, or HTML dump
  bool _isDeveloperOrTechnicalMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return true;
    if (trimmed.length > 180) return true;
    if (trimmed.startsWith('{') ||
        trimmed.startsWith('[') ||
        trimmed.startsWith('<')) {
      return true;
    }

    final lower = trimmed.toLowerCase();
    const technicalPatterns = [
      'dioexception',
      'bad response',
      'validatestatus',
      'requestoptions',
      'developer.mozilla.org',
      'status code of',
      '<!doctype',
      '<html',
      '<body',
      '<pre>',
      'cannot post',
      'cannot get',
      'cannot put',
      'typeerror',
      'referenceerror',
      'syntaxerror',
      'rangeerror',
      'axioserror',
      'sequelize',
      'prisma',
      'sqlstate',
      'econnrefused',
      'etimedout',
      'enotfound',
      'socketexception',
      'formatexception',
      'handshakeexception',
      'clientexception',
      'jsonwebtokenerror',
      'tokenexpirederror',
      'jwt malformed',
      'stacktrace',
      'at object.',
      'package:',
      'dart:',
      'internal server error',
      'unhandled',
      'exception:',
      'errno',
    ];

    for (final pattern in technicalPatterns) {
      if (lower.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Extracts a clean, user-friendly message from server response data if available
  String? _extractCleanServerMessage(dynamic data) {
    if (data == null) return null;

    String? candidate;
    if (data is Map) {
      final rawMessage = data['message'] ?? data['msg'];
      if (rawMessage is String && rawMessage.trim().isNotEmpty) {
        candidate = rawMessage.trim();
      } else if (data['error'] is String &&
          (data['error'] as String).trim().isNotEmpty) {
        candidate = (data['error'] as String).trim();
      } else if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          final first = errors.first;
          if (first is String) {
            candidate = first.trim();
          } else if (first is Map && first['message'] is String) {
            candidate = (first['message'] as String).trim();
          } else if (first is Map && first['msg'] is String) {
            candidate = (first['msg'] as String).trim();
          }
        } else if (errors is Map && errors.isNotEmpty) {
          final firstVal = errors.values.first;
          if (firstVal is String) {
            candidate = firstVal.trim();
          }
        }
      }
    } else if (data is String && data.trim().isNotEmpty) {
      candidate = data.trim();
    }

    if (candidate == null || candidate.isEmpty) return null;

    final lower = candidate.toLowerCase();
    if (lower.contains('jwt expired') ||
        lower.contains('token expired') ||
        lower.contains('invalid token')) {
      return "Your password reset session has expired. Please verify your phone number again.";
    }

    if (_isDeveloperOrTechnicalMessage(candidate)) {
      return null;
    }

    return candidate[0].toUpperCase() + candidate.substring(1);
  }

  /// Extract human-readable error messages for Forgot Password steps
  String _parseForgotPasswordError(dynamic error, {required String step}) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Request timed out. Please check your internet connection and try again.";
        case DioExceptionType.connectionError:
          return "No internet connection. Please check your network settings and try again.";
        case DioExceptionType.badResponse:
          final response = error.response;
          final cleanMsg = _extractCleanServerMessage(response?.data);
          if (cleanMsg != null) {
            return cleanMsg;
          }

          final statusCode = response?.statusCode;
          if (statusCode == 404) {
            if (step == 'send_otp' || step == 'resend_otp') {
              return "No account found with this phone number. Please check the number and try again.";
            }
            return "The requested service is currently unavailable. Please try again later.";
          } else if (statusCode == 400 || statusCode == 422) {
            if (step == 'send_otp' || step == 'resend_otp') {
              return "Please enter a valid registered 10-digit mobile number.";
            } else if (step == 'verify_otp') {
              return "Invalid verification code. Please check the 6-digit OTP and try again.";
            } else if (step == 'reset_password') {
              return "Unable to reset password. Please check your new password and try again.";
            }
          } else if (statusCode == 401 || statusCode == 403) {
            if (step == 'verify_otp') {
              return "Incorrect or expired OTP code. Please try again or request a new code.";
            } else if (step == 'reset_password') {
              return "Your reset session has expired. Please verify your phone number again.";
            }
            return "Unable to verify your request. Please check your details and try again.";
          } else if (statusCode == 429) {
            return "Too many attempts. Please wait a moment before trying again.";
          } else if (statusCode != null && statusCode >= 500) {
            return "Our server is temporarily unavailable. Please try again in a few moments.";
          }
          break;
        case DioExceptionType.cancel:
          return "Request was cancelled. Please try again.";
        default:
          if (error.error is SocketException) {
            return "No internet connection. Please check your network settings and try again.";
          }
          break;
      }
    } else if (error is SocketException) {
      return "No internet connection. Please check your network settings and try again.";
    }

    switch (step) {
      case 'send_otp':
        return "Unable to send verification code right now. Please try again.";
      case 'resend_otp':
        return "Unable to resend verification code right now. Please try again.";
      case 'verify_otp':
        return "Unable to verify the code. Please check the OTP and try again.";
      case 'reset_password':
        return "Unable to reset your password right now. Please try again.";
      default:
        return "Something went wrong. Please try again.";
    }
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
          final cleanMsg = _extractCleanServerMessage(response?.data);
          if (cleanMsg != null) {
            return cleanMsg;
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
          return "Unable to sign in right now. Please try again.";
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
    bool isLoginSuccess = false;

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
            _extractCleanServerMessage(data) ??
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
          await fetchSchoolsByParent(manageLoading: false);
        } catch (e) {
          log("Error fetching schools for parent: $e");
        }

        try {
          await AuthServices().sendFcmToken();
        } catch (e) {
          log("FCM token sync skipped/failed: $e");
        }

        isLoginSuccess = true;
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
          await fetchSchoolDetailsForTeacher(manageLoading: false);
        } catch (e) {
          log("Error fetching school details for teacher: $e");
        }

        isLoginSuccess = true;
        if (!context.mounted) return true;
        context.pushReplacementNamed(
          RouteConstants.bottomNavScreen,
          extra: UserType.teacher,
        );
      } else if (userRole == 'staff') {
        try {
          await fetchSchoolDetailsForTeacher(manageLoading: false);
        } catch (e) {
          log("Error fetching school details for staff: $e");
        }

        try {
          await getStaffPermissions(manageLoading: false);
        } catch (e) {
          log("Error fetching staff permissions: $e");
        }

        isLoginSuccess = true;
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
      if (!isLoginSuccess) {
        _isLoading = false;
        notifyListeners();
      }
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
  Future<void> fetchSchoolsByParent({bool manageLoading = true}) async {
    if (manageLoading) {
      _isLoading = true;
    }
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
      if (manageLoading) {
        _isLoading = false;
        notifyListeners();
      }
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
  Future<void> fetchSchoolDetailsForTeacher({bool manageLoading = true}) async {
    if (manageLoading) {
      _isLoading = true;
    }
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
      if (manageLoading) {
        _isLoading = false;
        notifyListeners();
      }
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
  Future<void> getStaffPermissions({bool manageLoading = true}) async {
    if (manageLoading) {
      _isLoading = true;
      notifyListeners();
    }

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
      if (manageLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // clear session data on logout
  Future<void> clearSession() async {
    await _storageService.clear();
    notifyListeners();
  }

  // ===================== FORGOT PASSWORD METHODS =====================

  /// Step 1: Send OTP for forgot password
  Future<bool> forgetPassword({
    required BuildContext context,
    required String phone,
  }) async {
    _isForgotPasswordLoading = true;
    _forgotPasswordError = null;
    notifyListeners();

    try {
      final response = await AuthServices().forgetPassword(phone: phone);
      log("ForgotPassword Response: ${response.data}");

      _forgotPasswordPhone = phone.trim();
      final message =
          _extractCleanServerMessage(response.data) ??
          "Verification code sent to your phone number";

      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.success,
        );
      }
      return true;
    } catch (e, stack) {
      log("ForgotPassword exception: $e", stackTrace: stack);
      _forgotPasswordError = _parseForgotPasswordError(e, step: 'send_otp');
      return false;
    } finally {
      _isForgotPasswordLoading = false;
      notifyListeners();
    }
  }

  /// Step 2a: Resend OTP to the given phone number
  Future<bool> resendOtp({
    required BuildContext context,
    required String phone,
  }) async {
    _isForgotPasswordLoading = true;
    _forgotPasswordError = null;
    notifyListeners();

    try {
      final response = await AuthServices().resendOtp(phone: phone);
      log("ResendOtp Response: ${response.data}");

      final message =
          _extractCleanServerMessage(response.data) ??
          "Verification code has been resent successfully";

      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.success,
        );
      }
      return true;
    } catch (e, stack) {
      log("ResendOtp exception: $e", stackTrace: stack);
      _forgotPasswordError = _parseForgotPasswordError(e, step: 'resend_otp');
      return false;
    } finally {
      _isForgotPasswordLoading = false;
      notifyListeners();
    }
  }

  /// Step 2b: Verify OTP and receive reset token
  Future<bool> verifyOtp({
    required BuildContext context,
    required String phone,
    required String otp,
  }) async {
    _isForgotPasswordLoading = true;
    _forgotPasswordError = null;
    notifyListeners();

    try {
      final response = await AuthServices().verifyOtp(
        phone: phone,
        otp: otp,
      );
      log("VerifyOtp Response: ${response.data}");

      String? token;
      if (response.data is Map) {
        final data = response.data as Map;
        token = data['resetToken']?.toString() ??
            data['data']?['resetToken']?.toString() ??
            data['token']?.toString() ??
            data['data']?['token']?.toString();
      }

      if (token == null || token.isEmpty) {
        _forgotPasswordError =
            _extractCleanServerMessage(response.data) ??
            "Could not verify the OTP code. Please request a new code and try again.";
        return false;
      }

      _resetToken = token;

      final message =
          _extractCleanServerMessage(response.data) ??
          "OTP verified successfully";

      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.success,
        );
      }
      return true;
    } catch (e, stack) {
      log("VerifyOtp exception: $e", stackTrace: stack);
      _forgotPasswordError = _parseForgotPasswordError(e, step: 'verify_otp');
      return false;
    } finally {
      _isForgotPasswordLoading = false;
      notifyListeners();
    }
  }

  /// Step 3: Set new password using resetToken
  Future<bool> resetPassword({
    required BuildContext context,
    required String newPassword,
    String? resetToken,
  }) async {
    final tokenToUse = resetToken ?? _resetToken;

    if (tokenToUse == null || tokenToUse.isEmpty) {
      _forgotPasswordError =
          "Your password reset session has expired. Please verify your phone number again.";
      notifyListeners();
      return false;
    }

    _isForgotPasswordLoading = true;
    _forgotPasswordError = null;
    notifyListeners();

    try {
      final response = await AuthServices().resetPassword(
        resetToken: tokenToUse,
        newPassword: newPassword,
      );
      log("ResetPassword Response: ${response.data}");

      final message =
          _extractCleanServerMessage(response.data) ??
          "Password has been reset successfully. Please sign in.";

      // Reset forgot password state on completion
      _resetToken = null;
      _forgotPasswordPhone = null;

      if (context.mounted) {
        CustomSnackbar.show(
          context,
          message: message,
          type: SnackbarType.success,
        );
      }
      return true;
    } catch (e, stack) {
      log("ResetPassword exception: $e", stackTrace: stack);
      _forgotPasswordError = _parseForgotPasswordError(
        e,
        step: 'reset_password',
      );
      return false;
    } finally {
      _isForgotPasswordLoading = false;
      notifyListeners();
    }
  }
}
