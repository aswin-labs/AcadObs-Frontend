import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class PaymentStatusStyle {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const PaymentStatusStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}

PaymentStatusStyle getPaymentStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return const PaymentStatusStyle(
        icon: LucideIcons.clock,
        iconColor: Colors.orange,
        backgroundColor: Color(0xFFFFF3E0),
      );
    case 'completed':
      return const PaymentStatusStyle(
        icon: LucideIcons.checkCircle2,
        iconColor: Colors.green,
        backgroundColor: Color(0xFFE8F5E9),
      );
    case 'partially_completed':
      return const PaymentStatusStyle(
        icon: LucideIcons.alertTriangle,
        iconColor: Colors.yellow,
        backgroundColor: Color(0xFFFFFDE7),
      );
    case 'failed':
      return const PaymentStatusStyle(
        icon: LucideIcons.xCircle,
        iconColor: Colors.red,
        backgroundColor: Color(0xFFFFEBEE),
      );
    default:
      return const PaymentStatusStyle(
        icon: LucideIcons.helpCircle,
        iconColor: Colors.grey,
        backgroundColor: Color(0xFFF5F5F5),
      );
  }
}
