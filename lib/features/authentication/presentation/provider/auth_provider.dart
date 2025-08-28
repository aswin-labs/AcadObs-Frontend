// lib/providers/login_provider.dart
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/data/services/auth_services.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthProvider with ChangeNotifier {
  final AuthStorageService _storageService = AuthStorageService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ⬇️ Call your API here
      final response = await AuthServices().login(
        email: email,
        password: password,
      );

      // Save in secure storage
      await _storageService.saveUserCredentials(
        token: response.data['token'],
        userData: response.data['userData'],
      );

      if (response.statusCode == 200) {
        final userRole = await _storageService.getUserRole();
        if (!context.mounted) return;
        if (userRole == 'parent') {
          context.pushNamed(
            RouteConstants.bottomNavScreen,
            extra: UserType.parent,
          );
        } else if (userRole == 'teacher') {
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

      // ✅ Login successful
    } catch (e) {
      debugPrint("Login error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getToken() => _storageService.getToken();
  Future<Map<String, dynamic>?> getUserData() => _storageService.getUserData();

  Future<void> logout(BuildContext context) async {
    await _storageService.clear();
    if(!context.mounted) return;
    context.pushReplacementNamed(RouteConstants.loginScreen);
    notifyListeners();
  }
}
