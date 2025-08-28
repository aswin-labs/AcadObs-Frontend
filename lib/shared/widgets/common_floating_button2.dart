import 'package:flutter/material.dart';

class CommonFloatingButton2 extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  const CommonFloatingButton2({
    super.key,
    required this.onPressed,
    required this.icon,
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
