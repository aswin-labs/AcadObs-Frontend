import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleBackToExit extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration duration;

  const DoubleBackToExit({
    super.key,
    required this.child,
    this.message = "Press back again to exit",
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        final now = DateTime.now();

        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > widget.duration) {
          _lastBackPressed = now;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(widget.message),
                duration: widget.duration,
              ),
            );
        } else {
          SystemNavigator.pop();
        }
      },
      child: widget.child,
    );
  }
}
