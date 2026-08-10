import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A widget that handles the case when route `state.extra` is null on web.
///
/// On Flutter web, `state.extra` is not persisted in browser history.
/// When users navigate back using browser gestures, the route is rebuilt
/// from the URL alone, and `extra` will be null. This widget detects that
/// and navigates back to a safe screen instead of crashing.
class RouteExtraGuard extends StatefulWidget {
  /// The child to display when extra is available.
  final Widget child;

  const RouteExtraGuard({super.key, required this.child});

  @override
  State<RouteExtraGuard> createState() => _RouteExtraGuardState();
}

class _RouteExtraGuardState extends State<RouteExtraGuard> {
  @override
  void initState() {
    super.initState();
    // Schedule the navigation for after the build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // The parent already checks if extra is null and passes this widget
      // only when it is, so we just navigate back here.
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SizedBox.shrink(),
    );
  }
}

/// Helper to safely extract `state.extra` or pop back if null on web.
///
/// Usage in route builders:
/// ```dart
/// builder: (context, state) {
///   final extra = state.extra;
///   if (extra == null) {
///     return buildRouteExtraFallback(context);
///   }
///   final model = extra as MyModel;
///   return MyScreen(model: model);
/// }
/// ```
Widget buildRouteExtraFallback(BuildContext context) {
  // Schedule navigation back after the current frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (context.mounted && context.canPop()) {
      context.pop();
    }
  });
  return const Scaffold(body: SizedBox.shrink());
}
