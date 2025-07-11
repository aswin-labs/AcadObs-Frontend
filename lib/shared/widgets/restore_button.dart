import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Optional: Use any icon

class RestoreButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String? label;
  final Color? color;
  final IconData? icon;

  const RestoreButton({
    super.key,
    required this.onPressed,
    this.label,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? LucideIcons.rotateCcw, color: color ?? Colors.blue),
      label: Text(
        label ?? 'Restore',
        style: TextStyle(color: color ?? Colors.blue),
      ),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
