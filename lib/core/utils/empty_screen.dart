import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

Widget emptyScreen({double heightMultiplier = 30, required String message}) {
  return Center(
    child: Column(
      children: [
        SizedBox(height: Responsive.height * heightMultiplier),
        Icon(LucideIcons.calendarX, size: 36, color: Colors.grey.shade400),
        SizedBox(height: 8),
        Text(
          message,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
