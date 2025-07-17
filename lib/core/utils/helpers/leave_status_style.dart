import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LeaveStatusStyle {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const LeaveStatusStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}

LeaveStatusStyle getLeaveStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const LeaveStatusStyle(
        icon: LucideIcons.clock,
        iconColor: Colors.orange,
        backgroundColor: Color(0xFFFFF3E0),
      );
    case 'approved':
      return const LeaveStatusStyle(
        icon: LucideIcons.checkCircle2,
        iconColor: Colors.green,
        backgroundColor: Color(0xFFE8F5E9),
      );
    case 'rejected':
      return const LeaveStatusStyle(
        icon: LucideIcons.xCircle,
        iconColor: Colors.red,
        backgroundColor: Color(0xFFFFEBEE),
      );
    default:
      return const LeaveStatusStyle(
        icon: LucideIcons.helpCircle,
        iconColor: Colors.grey,
        backgroundColor: Color(0xFFF5F5F5),
      );
  }
}
