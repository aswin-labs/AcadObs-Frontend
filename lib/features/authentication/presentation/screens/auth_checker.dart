import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';

const Color tBackgroundColor = Color(0xFFF4F6F9);

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  final AuthStorageService _authStorage = AuthStorageService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final results = await Future.wait([
      _authStorage.getToken(),
      _authStorage.getUserRole(),
    ]);
    final token = results[0];
    final userRole = results[1];
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      if (userRole == 'guardian') {
        context.pushReplacementNamed(
          RouteConstants.bottomNavScreen,
          extra: UserType.parent,
        );
      } else if (userRole == 'teacher') {
        context.pushReplacementNamed(
          RouteConstants.bottomNavScreen,
          extra: UserType.teacher,
        );
      } else if (userRole == 'staff') {
        context.pushReplacementNamed(
          RouteConstants.bottomNavScreen,
          extra: UserType.nonTeachingStaff,
        );
      }
      return;
    } else {
      context.pushReplacementNamed(RouteConstants.loginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tBackgroundColor,
      body: Center(
        child: SizedBox(height: 120, child: Image.asset("assets/logo.png")),
      ),
    );
  }
}
