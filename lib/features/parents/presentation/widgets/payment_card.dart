import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/payment_status_style.dart';
import 'package:acadobs/features/parents/data/models/invoice_student_model.dart';
import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/features/parents/data/models/transport_invoice_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// A modern, recognizable financial card designed for invoices, transport dues,
/// and payment history in the parent payment section.
class PaymentCard extends StatelessWidget {
  final String title;
  final String amount;
  final String status;
  final IconData leadingIcon;
  final Color? leadingColor;
  final Color? leadingBgColor;
  final String? category;
  final String? subtitle;
  final String? dateLabel;
  final DateTime? date;
  final bool isOverdue;
  final String? badgeTag;
  final String? pendingInfo;
  final String? paidInfo;
  final VoidCallback onTap;

  const PaymentCard({
    super.key,
    required this.title,
    required this.amount,
    required this.status,
    required this.leadingIcon,
    this.leadingColor,
    this.leadingBgColor,
    this.category,
    this.subtitle,
    this.dateLabel,
    this.date,
    this.isOverdue = false,
    this.badgeTag,
    this.pendingInfo,
    this.paidInfo,
    required this.onTap,
  });

  /// Factory constructor for General Student Invoices
  factory PaymentCard.invoice({
    Key? key,
    required InvoiceStudent invoice,
    required VoidCallback onTap,
  }) {
    final status = invoice.status ?? "pending";
    final dueDate = invoice.invoice?.dueDate;
    final isOverdue =
        status.toLowerCase() == 'overdue' ||
        (status.toLowerCase() == 'pending' &&
            dueDate != null &&
            dueDate.isBefore(DateTime.now()));

    final statusStyle = getPaymentStatusStyle(isOverdue ? 'overdue' : status);
    final rawAmount = invoice.invoice?.amount ?? "0";
    final formattedAmount =
        rawAmount.startsWith("₹") ? rawAmount : "₹$rawAmount";

    return PaymentCard(
      key: key,
      title: invoice.invoice?.title?.trim().isNotEmpty == true
          ? invoice.invoice!.title!
          : "School Fee",
      amount: formattedAmount,
      status: isOverdue ? "overdue" : status,
      leadingIcon: LucideIcons.receiptText,
      leadingColor: statusStyle.iconColor,
      leadingBgColor: statusStyle.backgroundColor,
      category: invoice.invoice?.category,
      dateLabel: isOverdue ? "Overdue" : "Due",
      date: dueDate ?? invoice.createdAt,
      isOverdue: isOverdue,
      onTap: onTap,
    );
  }

  /// Factory constructor for Payment Records
  factory PaymentCard.payment({
    Key? key,
    required Payment payment,
    required VoidCallback onTap,
  }) {
    final status = payment.paymentStatus ?? "paid";
    final statusStyle = getPaymentStatusStyle(status);
    final rawAmount = payment.amount ?? "0";
    final formattedAmount =
        rawAmount.startsWith("₹") ? rawAmount : "₹$rawAmount";

    final title =
        payment.invoiceStudent?.invoice?.title ??
        payment.paymentCategory ??
        "Fee Payment";

    final subtitle =
        payment.transactionId != null &&
                payment.transactionId!.trim().isNotEmpty
            ? "Txn: ${payment.transactionId}"
            : (payment.paymentCategory != null &&
                    payment.paymentCategory != title
                ? payment.paymentCategory
                : null);

    return PaymentCard(
      key: key,
      title: title,
      amount: formattedAmount,
      status: status,
      leadingIcon: LucideIcons.checkCheck,
      leadingColor: statusStyle.iconColor,
      leadingBgColor: statusStyle.backgroundColor,
      subtitle: subtitle,
      badgeTag: payment.paymentMethod?.trim().isNotEmpty == true
          ? payment.paymentMethod!.toUpperCase()
          : null,
      dateLabel: "Paid on",
      date: payment.paymentDate ?? payment.createdAt,
      onTap: onTap,
    );
  }

  /// Factory constructor for Transport Invoices
  factory PaymentCard.transport({
    Key? key,
    required TransportInvoice invoice,
    required VoidCallback onTap,
  }) {
    final status = invoice.status ?? "pending";
    final dueDate = invoice.dueDate;
    final isOverdue =
        status.toLowerCase() == 'overdue' ||
        (status.toLowerCase() == 'pending' &&
            dueDate != null &&
            dueDate.isBefore(DateTime.now()));

    final statusStyle = getPaymentStatusStyle(isOverdue ? 'overdue' : status);
    final rawAmount = invoice.amount ?? "0";
    final formattedAmount =
        rawAmount.startsWith("₹") ? rawAmount : "₹$rawAmount";

    final stopName = invoice.stop?.stopName;
    final subtitle =
        stopName != null && stopName.trim().isNotEmpty
            ? "Stop: $stopName"
            : null;

    final term = invoice.term?.trim();
    final title = term != null && term.isNotEmpty
        ? "$term Transport Fee"
        : "Transport Fee";

    return PaymentCard(
      key: key,
      title: title,
      amount: formattedAmount,
      status: isOverdue ? "overdue" : status,
      leadingIcon: LucideIcons.bus,
      leadingColor: statusStyle.iconColor,
      leadingBgColor: statusStyle.backgroundColor,
      subtitle: subtitle,
      dateLabel: isOverdue ? "Overdue" : "Due",
      date: dueDate ?? invoice.createdAt,
      isOverdue: isOverdue,
      pendingInfo:
          invoice.isPartiallyPaid && invoice.formattedPendingAmount != null
              ? "Due: ₹${invoice.formattedPendingAmount}"
              : null,
      paidInfo:
          invoice.isPartiallyPaid && invoice.formattedTotalPaid != null
              ? "Paid: ₹${invoice.formattedTotalPaid}"
              : null,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = getPaymentStatusStyle(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: statusStyle.iconColor.withAlpha(20),
          highlightColor: statusStyle.iconColor.withAlpha(10),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Leading Icon + Title / Subtitle + Status Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: leadingBgColor ?? statusStyle.backgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: (leadingColor ?? statusStyle.iconColor)
                              .withAlpha(40),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        leadingIcon,
                        color: leadingColor ?? statusStyle.iconColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Category / Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalizeEachWord(title),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          if (category != null && category!.trim().isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    capitalizeEachWord(category!),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else if (subtitle != null &&
                              subtitle!.trim().isNotEmpty)
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            )
                          else
                            const SizedBox(height: 4),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Status Chip
                    _StatusChip(statusStyle: statusStyle),
                  ],
                ),

                const SizedBox(height: 12),

                // Subtle Voucher Divider
                Container(
                  height: 1,
                  color: const Color(0xFFF1F5F9),
                ),

                const SizedBox(height: 10),

                // Bottom Row: Amount on Left, Date & Action on Right
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Amount Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "AMOUNT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF94A3B8),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            amount,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          // Partial payment breakdowns if any
                          if (pendingInfo != null || paidInfo != null) ...[
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (paidInfo != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      paidInfo!,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                if (pendingInfo != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      pendingInfo!,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Date & Action Indicator
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (badgeTag != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              badgeTag!,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF475569),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (date != null) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isOverdue
                                        ? LucideIcons.alertTriangle
                                        : LucideIcons.calendar,
                                    size: 13,
                                    color: isOverdue
                                        ? const Color(0xFFEF4444)
                                        : const Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    dateLabel ?? "Date",
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: isOverdue
                                          ? const Color(0xFFEF4444)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                DateFormat('dd MMM yyyy').format(date!),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isOverdue
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                        ],

                        // Interactive Chevron Circle
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.chevronRight,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final PaymentStatusStyle statusStyle;

  const _StatusChip({required this.statusStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: statusStyle.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusStyle.iconColor.withAlpha(50),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusStyle.icon,
            size: 12.5,
            color: statusStyle.iconColor,
          ),
          const SizedBox(width: 4.5),
          Text(
            statusStyle.label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: statusStyle.iconColor,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
