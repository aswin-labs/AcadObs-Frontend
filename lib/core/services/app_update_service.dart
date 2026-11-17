import 'package:flutter/foundation.dart';
import 'package:upgrader/upgrader.dart';

class AppUpdateService {
  /// Shared [Upgrader] instance configured for in-app updates.
  static final Upgrader upgrader = Upgrader(
    debugLogging: kDebugMode,
    durationUntilAlertAgain: const Duration(days: 1),
  );

  /// Initializes the upgrader and checks for updates.
  static Future<void> checkForUpdate() async {
    if (kIsWeb) return;
    try {
      await upgrader.initialize();
    } catch (e) {
      debugPrint("App update check failed: $e");
    }
  }
}
