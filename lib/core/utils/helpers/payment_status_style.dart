import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class PaymentStatusStyle {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  /// Human-readable label (underscores replaced with spaces, title-cased).
  final String label;

  const PaymentStatusStyle({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.label,
  });
}

/// Returns a human-readable label for [status] by replacing underscores with
/// spaces and title-casing each word (e.g. "partially_paid" → "Partially Paid").
String getStatusLabel(String status) {
  return status
      .replaceAll('_', ' ')
      .split(' ')
      .map(
        (w) =>
            w.isEmpty
                ? w
                : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
      )
      .join(' ');
}

PaymentStatusStyle getPaymentStatusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return PaymentStatusStyle(
        icon: LucideIcons.clock,
        iconColor: const Color.fromARGB(255, 255, 162, 1), // amber
        backgroundColor: const Color.fromARGB(255, 255, 236, 179),
        label: getStatusLabel(status),
      );
    case 'partially_paid':
      return PaymentStatusStyle(
        icon: LucideIcons.splitSquareHorizontal,
        iconColor: const Color(0xFFF97316), // orange
        backgroundColor: const Color.fromARGB(255, 254, 221, 177),
        label: getStatusLabel(status),
      );
    case 'paid':
      return PaymentStatusStyle(
        icon: LucideIcons.checkCircle2,
        iconColor: const Color(0xFF22C55E), // green
        backgroundColor: const Color(0xFFDCFCE7),
        label: getStatusLabel(status),
      );
    case 'overdue':
      return PaymentStatusStyle(
        icon: LucideIcons.alertCircle,
        iconColor: const Color(0xFFEF4444), // red
        backgroundColor: const Color(0xFFFEE2E2),
        label: getStatusLabel(status),
      );
    case 'waiting_for_approval':
      return PaymentStatusStyle(
        icon: LucideIcons.hourglass,
        iconColor: const Color(0xFF3B82F6), // blue
        backgroundColor: const Color(0xFFDBEAFE),
        label: getStatusLabel(status),
      );
    // Legacy statuses kept for backwards compatibility
    case 'completed':
      return PaymentStatusStyle(
        icon: LucideIcons.checkCircle2,
        iconColor: const Color(0xFF22C55E),
        backgroundColor: const Color(0xFFDCFCE7),
        label: getStatusLabel(status),
      );
    case 'partially_completed':
      return PaymentStatusStyle(
        icon: LucideIcons.alertTriangle,
        iconColor: const Color(0xFFF59E0B),
        backgroundColor: const Color(0xFFFEF3C7),
        label: getStatusLabel(status),
      );
    case 'failed':
      return PaymentStatusStyle(
        icon: LucideIcons.xCircle,
        iconColor: const Color(0xFFEF4444),
        backgroundColor: const Color(0xFFFEE2E2),
        label: getStatusLabel(status),
      );
    default:
      return PaymentStatusStyle(
        icon: LucideIcons.helpCircle,
        iconColor: Colors.grey,
        backgroundColor: const Color(0xFFF5F5F5),
        label: getStatusLabel(status),
      );
  }
}
