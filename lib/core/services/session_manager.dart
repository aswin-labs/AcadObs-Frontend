import 'package:acadobs/core/utils/auth_storage_services.dart';
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

  void reset() {
    _loggedOut = false;
  }

  Future<void> forceLogout() async {
    if (_loggedOut) return;
    _loggedOut = true;

    await authProvider?.clearSession();
    await AuthStorageService().clear();

    router.goNamed(RouteConstants.loginScreen);
  }
}