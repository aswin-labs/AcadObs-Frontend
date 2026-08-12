import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/payment_status_style.dart';
import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/features/parents/presentation/widgets/create_payment_bottomsheet.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/download_file_card.dart';
import 'package:flutter/material.dart';

class PaymentDetailScreen extends StatelessWidget {
  final Payment payment;

  const PaymentDetailScreen({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    final paymentStatusStyle = getPaymentStatusStyle(
      payment.paymentStatus ?? "",
    );

    final isDonation = payment.paymentCategory == "donation";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: CommonAppBar(
        title: "Payment Details",
        isBackButton: true,
        actions: [
          if (payment.paymentStatus == "pending" && !isDonation)
            TextButton.icon(
              onPressed: () {
                showCreatePaymentBottomSheet(
                  context: context,
                  invoice: payment.invoiceStudent!,
                  transactionId: payment.transactionId,
                  forEdit: true,
                  paymentId: payment.id,
                );
              },
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text("Edit"),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Payment summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
              decoration: BoxDecoration(
                color: paymentStatusStyle.backgroundColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Container(
                    height: 54,
                    width: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(190),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDonation
                          ? Icons.volunteer_activism_outlined
                          : Icons.payments_outlined,
                      color: paymentStatusStyle.iconColor,
                      size: 28,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "₹ ${payment.amount ?? "0.00"}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    isDonation
                        ? "Donation"
                        : capitalizeEachWord(
                          payment.invoiceStudent?.invoice?.title ?? "Payment",
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      paymentStatusStyle.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: paymentStatusStyle.iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Payment information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  if (!isDonation) ...[
                    _detailRow(
                      icon: Icons.receipt_long_outlined,
                      label: "Invoice",
                      value: payment.invoiceStudent?.invoice?.title ?? "N/A",
                    ),

                    const Divider(height: 28),
                  ],

                  _detailRow(
                    icon: Icons.category_outlined,
                    label: "Category",
                    value: capitalizeEachWord(
                      (payment.paymentCategory ?? "N/A").replaceAll("_", " "),
                    ),
                  ),

                  if (!isDonation) ...[
                    const Divider(height: 28),

                    _detailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: "Invoice Amount",
                      value:
                          "₹ ${payment.invoiceStudent?.invoice?.amount ?? "0.00"}",
                    ),

                    const Divider(height: 28),

                    _detailRow(
                      icon: Icons.event_outlined,
                      label: "Invoice Due Date",
                      value:
                          payment.invoiceStudent?.invoice?.dueDate != null
                              ? DateFormatter.formatDateTime(
                                payment.invoiceStudent!.invoice!.dueDate!,
                              )
                              : "N/A",
                    ),
                  ],

                  const Divider(height: 28),

                  _detailRow(
                    icon: Icons.calendar_today_outlined,
                    label: "Payment Date",
                    value:
                        payment.paymentDate != null
                            ? DateFormatter.formatDateTime(payment.paymentDate!)
                            : "N/A",
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: "Payment Method",
                    value: capitalizeEachWord(
                      (payment.paymentMethod ?? "N/A").replaceAll("_", " "),
                    ),
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    icon: Icons.tag_outlined,
                    label: "Transaction ID",
                    value:
                        payment.transactionId?.isNotEmpty == true
                            ? payment.transactionId!
                            : "N/A",
                  ),

                  const Divider(height: 28),

                  _detailRow(
                    icon: Icons.notes_outlined,
                    label: "Remarks",
                    value:
                        payment.remarks?.isNotEmpty == true
                            ? payment.remarks!
                            : "N/A",
                  ),
                ],
              ),
            ),

            if (payment.paymentAttachment?.isNotEmpty == true) ...[
              const SizedBox(height: 16),

              DownloadFileCard(fileName: payment.paymentAttachment!),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey),

        const SizedBox(width: 12),

        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          flex: 5,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
