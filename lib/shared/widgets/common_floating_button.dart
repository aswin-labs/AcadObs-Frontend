import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CommonFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData? icon;
  const CommonFloatingButton({
    super.key,
    required this.onPressed,
    this.icon = LucideIcons.plus,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      shape: CircleBorder(),

      onPressed: onPressed,
      child: Icon(icon, color: Colors.grey),
    );
  }
}
