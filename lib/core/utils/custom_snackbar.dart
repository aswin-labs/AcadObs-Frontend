import 'package:flutter/material.dart';

class CustomSnackbar {
  static show(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    double bottomPadding =
        20.0, // You can adjust this value to change the height
  }) {
    final Color backgroundColor;
    final Icon icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = Colors.green;
        icon = const Icon(Icons.check_circle, color: Colors.white);
        break;
      case SnackbarType.failure:
        backgroundColor = Colors.red;
        icon = const Icon(Icons.error, color: Colors.white);
        break;
      case SnackbarType.warning:
        backgroundColor = Colors.orange;
        icon = const Icon(Icons.warning, color: Colors.white);
        break;
      default:
        backgroundColor = Colors.blue;
        icon = const Icon(Icons.info, color: Colors.white);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            icon, // Add the icon to the Snackbar
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        behavior:
            SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.only(
          bottom: bottomPadding,
          left: 16,
          right: 16,
        ),
      ),
    );
  }
}

enum SnackbarType { success, failure, warning, info }
