import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CommonFloatingButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CommonFloatingButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      shape: CircleBorder(),

      onPressed: onPressed,
      child: Icon(LucideIcons.plus, color: Colors.grey),
    );
  }
}
