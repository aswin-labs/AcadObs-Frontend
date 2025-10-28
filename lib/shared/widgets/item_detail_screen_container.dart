import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class ItemDetailScreenContainer extends StatelessWidget {
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  const ItemDetailScreenContainer({
    super.key,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.width * 20,
          vertical: Responsive.height * 3,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: Responsive.width * 50, color: iconColor),
      ),
    );
  }
}
