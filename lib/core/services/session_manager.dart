import 'package:acadobs/features/authentication/presentation/provider/auth_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:go_router/go_router.dart';

class SessionManager {
  final GoRouter router;

  SessionManager({
    required this.router,
  });

  AuthProvider? authProvider;

  bool _loggedOut = false;

  Future<void> init(AuthProvider provider) async {
    authProvider = provider;
  }

  Future<void> forceLogout() async {
    if (_loggedOut) return;
    _loggedOut = true;

    await authProvider?.clearSession();

    router.goNamed(RouteConstants.loginScreen);
  }
}