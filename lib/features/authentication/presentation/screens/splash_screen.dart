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

class _SplashScreenState extends State<SplashScreen> {
  final AuthStorageService _authStorage = AuthStorageService();

  @override
  void initState() {
    super.initState();
    // _checkLogin();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogin();
    });
  }

  Future<void> _checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = await _authStorage.getToken();
    final userRole = await _authStorage.getUserRole();
    if (!mounted) return;
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
      context.pushReplacementNamed(RouteConstants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  height: 140,
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/acadobs_logo.jpg',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 32),

                const Text(
                  'AcadObs',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: tPrimaryColor,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Smart School Management',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),

                const SizedBox(height: 48),

                const CircularProgressIndicator(color: Colors.black),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
