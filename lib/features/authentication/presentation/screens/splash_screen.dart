// lib/screens/splash_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthStorageService _authStorage = AuthStorageService();

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Simulate splash delay (optional)
    await Future.delayed(const Duration(seconds: 2));

    final token = await _authStorage.getToken();
    final userRole = await _authStorage.getUserRole();

    if (token != null && token.isNotEmpty) {
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
    } else {
      // No token → go to LoginPage
      context.pushReplacementNamed(RouteConstants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // simple loader
      ),
    );
  }
}
