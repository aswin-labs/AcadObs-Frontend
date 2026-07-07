import 'dart:io';

import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/payment_status_style.dart';
import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class PaymentDetailScreen extends StatefulWidget {
  final Payment payment;
  const PaymentDetailScreen({super.key, required this.payment});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController transactionController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    transactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.payment;

    final paymentStatusStyle = getPaymentStatusStyle(
      payment.paymentStatus ?? "",
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: CommonAppBar(title: "Payment Details", isBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: paymentStatusStyle.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    height: 86,
                    width: 86,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(180),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.payment,
                      color: paymentStatusStyle.iconColor,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "₹${payment.amount}",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: paymentStatusStyle.iconColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    capitalizeEachWord(payment.paymentType ?? ""),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(190),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      capitalizeEachWord(payment.paymentStatus ?? ""),
                      style: TextStyle(
                        fontSize: 13,
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
                        DateFormatter.formatDateTime(
                          payment.paymentDate ?? DateTime.now(),
                        ),
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
                          payment.transactionId ?? "N/A",
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
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

            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: CommonFloatingButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            enableDrag: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 50,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),

                        const Text(
                          "Add Payment",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 15),

                        CustomTextfield(
                          controller: amountController,
                          iconData: const Icon(Icons.attach_money),
                          hintText: 'Amount',
                          borderRadius: 8,
                        ),
                        const SizedBox(height: 10),

                        CustomDatePicker(
                          label: "Payment Date",
                          dateController: dateController,
                          onDateSelected: (selectedDate) {
                            dateController.text = selectedDate.toString();
                          },
                        ),

                        const SizedBox(height: 10),

                        CustomTextfield(
                          controller: transactionController,
                          iconData: const Icon(Icons.receipt_long),
                          hintText: 'Transaction ID',
                          borderRadius: 8,
                        ),

                        const SizedBox(height: 20),
                        CustomFilePicker(
                          label: "Upload File (Max 5 mb):",
                          fieldName: "solved_file",
                        ),
                        const SizedBox(height: 20),

                        SizedBox(
                          width: double.infinity,
                          child: CommonButton(
                            onPressed: () {
                              final fileProvider =
                                  context.read<FilePickerProvider>();
                              final platformFile = fileProvider.getFile(
                                "solved_file",
                              );
                              final File? selectedFile =
                                  platformFile != null
                                      ? File(platformFile.path!)
                                      : null;
                              final amount = amountController.text;
                              context
                                  .read<PaymentProvider>()
                                  .uploadPaymentDetails(
                                    context: context,
                                    studentId: widget.payment.studentId ?? 0,
                                    invoiceStudentId:
                                        widget.payment.inVoiceStudentId ?? 0,
                                    amount: int.parse(amount),
                                    paymentDate: dateController.text.trim(),
                                    paymentType:
                                        widget.payment.paymentType ?? "",
                                    transactionId:
                                        transactionController.text
                                            .toString()
                                            .trim(),
                                    paymentMethod:
                                        widget.payment.paymentMethod ?? "",
                                    paymentAttachment: selectedFile,
                                  );
                              amountController.clear();
                              dateController.clear();
                              transactionController.clear();
                              fileProvider.clearFile("solved_file");
                              context.pop();
                            },
                            widget: const Text('Upload'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
