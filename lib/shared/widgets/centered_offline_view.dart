import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class CenteredOfflineView extends StatefulWidget {
  final Future<void> Function()? onRetry;
  final String title;
  final String message;

  const CenteredOfflineView({
    super.key,
    this.onRetry,
    this.title = "You're Offline",
    this.message =
        "Check your connection and tap retry to reload your dashboard.",
  });

  @override
  State<CenteredOfflineView> createState() => _CenteredOfflineViewState();
}

class _CenteredOfflineViewState extends State<CenteredOfflineView> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);

    try {
      final connectivity = await Connectivity().checkConnectivity();
      final hasConnection = connectivity.any((r) => r != ConnectivityResult.none);

      if (widget.onRetry != null) {
        await widget.onRetry!();
      }

      if (!hasConnection && mounted) {
        CustomSnackbar.show(
          context,
          message: "Still no internet connection. Please check your network.",
          type: SnackbarType.warning,
        );
      }
    } catch (_) {
      // Handled gracefully
    } finally {
      if (mounted) {
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRetry,
      color: const Color(0xFF00AEF0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Outer stylized circle with glowing accent
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF00AEF0).withAlpha(18),
                      ),
                      child: Center(
                        child: Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF35C2C1), Color(0xFF00AEF0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00AEF0).withAlpha(60),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 10),

                    // Message description
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Retry button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isRetrying ? null : _handleRetry,
                        borderRadius: BorderRadius.circular(28),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF35C2C1), Color(0xFF00AEF0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00AEF0).withAlpha(50),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 13,
                            ),
                            child: _isRetrying
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Try Again",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Swipe hint
                    Text(
                      "or swipe down to refresh",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
