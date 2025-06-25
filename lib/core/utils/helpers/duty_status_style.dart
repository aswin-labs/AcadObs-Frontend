import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DutyStatusStyle {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const DutyStatusStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}

DutyStatusStyle getDutyStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const DutyStatusStyle(
        icon: LucideIcons.clock,
        iconColor: Colors.orange,
        backgroundColor: Color(0xFFFFF3E0),
      );
    case 'in progress'|| 'in_progress':
      return const DutyStatusStyle(
        icon: LucideIcons.loader2,
        iconColor: Colors.blue,
        backgroundColor: Color(0xFFE3F2FD),
      );
    case 'completed':
      return const DutyStatusStyle(
        icon: LucideIcons.checkCircle2,
        iconColor: Colors.green,
        backgroundColor: Color(0xFFE8F5E9),
      );
    default:
      return const DutyStatusStyle(
        icon: LucideIcons.helpCircle,
        iconColor: Colors.grey,
        backgroundColor: Color(0xFFF5F5F5),
      );
  }
}
