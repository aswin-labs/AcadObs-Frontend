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

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: CommonAppBar(
        title: "Details",
        isBackButton: true,
        actions: [
          if (payment.paymentStatus == "pending")
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              decoration: BoxDecoration(
                color: paymentStatusStyle.backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    "₹ ${payment.amount ?? ""}",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    capitalizeEachWord(
                      payment.invoiceStudent?.invoice?.title ?? "N/A",
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(190),
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
                  Row(
                    children: [
                      const Icon(
                        Icons.receipt_long_outlined,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Invoice",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          payment.invoiceStudent?.invoice?.title ?? "N/A",
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  Row(
                    children: [
                      const Icon(
                        Icons.category_outlined,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Category",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        capitalizeEachWord(
                          payment.invoiceStudent?.invoice?.category ??
                              payment.paymentType ??
                              "N/A",
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Invoice Amount",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "₹${payment.invoiceStudent?.invoice?.amount ?? "0.00"}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Invoice Due Date",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        payment.invoiceStudent?.invoice?.dueDate != null
                            ? DateFormatter.formatDateTime(
                              payment.invoiceStudent!.invoice!.dueDate!,
                            )
                            : "N/A",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 19,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Payment Date",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        payment.paymentDate != null
                            ? DateFormatter.formatDateTime(payment.paymentDate!)
                            : "N/A",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Payment Method",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        capitalizeEachWord(payment.paymentMethod ?? "N/A"),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  Row(
                    children: [
                      const Icon(
                        Icons.tag_outlined,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Transaction ID",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          payment.transactionId?.isNotEmpty == true
                              ? payment.transactionId!
                              : "N/A",
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 28),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes_outlined,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Remarks",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          payment.remarks?.isNotEmpty == true
                              ? payment.remarks!
                              : "N/A",
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (payment.paymentAttachment != null)
              DownloadFileCard(fileName: payment.paymentAttachment ?? ""),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
