import 'dart:io';

import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';

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
    return Scaffold(
      appBar: CommonAppBar(
        title: capitalizeEachWord(widget.payment.paymentType.toString()),
        isBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 226,
              decoration: BoxDecoration(
                color: const Color(0xFFCEFFD3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(Icons.payment, color: Color(0xFF5DD168), size: 150),
              ),
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    capitalizeEachWord(widget.payment.paymentType.toString()),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                ],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "₹${widget.payment.amount}",
                    style: TextStyle(color: Color(0xFF949494)),
                  ),
                ),
                Spacer(),

                Text(
                  DateFormatter.formatDateTime(
                    widget.payment.paymentDate ?? DateTime.now(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
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
