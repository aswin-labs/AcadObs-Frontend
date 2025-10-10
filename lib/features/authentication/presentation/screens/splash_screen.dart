// lib/screens/splash_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const Color tPrimaryColor = Color(0xFF1E88E5);
const Color tBackgroundColor = Color(0xFFF4F6F9);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthStorageService _authStorage = AuthStorageService();

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);

    // _checkLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogin();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkLogin() async {
    // Simulate splash delay (optional)
    await Future.delayed(const Duration(seconds: 3));

    final token = await _authStorage.getToken();
    final userRole = await _authStorage.getUserRole();

    if (token != null && token.isNotEmpty) {
      if (userRole == 'guardian') {
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
    return Scaffold(
      backgroundColor: tBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(scale: _animation.value, child: child);
              },
              child: SizedBox(
                height: 150,
                width: 150,
                child: Image.asset('assets/logo.png', fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
