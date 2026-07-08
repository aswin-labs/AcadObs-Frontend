import 'dart:io';

import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/features/parents/data/models/invoice_model.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class InvoiceDetailScreen extends StatefulWidget {
  final InvoiceModel invoice;
  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  State<InvoiceDetailScreen> createState() => _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends State<InvoiceDetailScreen> {
  late TextEditingController amountController;
  late TextEditingController paymentDateController;
  late TextEditingController transactionController;
  String? selectedMethod;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(
      text: widget.invoice.invoice?.amount ?? "",
    );
    paymentDateController = TextEditingController(
      text:
          widget.invoice.invoice?.createdAt != null
              ? DateFormat(
                'yyyy-MM-dd',
              ).format(widget.invoice.invoice!.createdAt!)
              : "",
    );
    transactionController = TextEditingController();
  }

  @override
  void dispose() {
    amountController.dispose();
    paymentDateController.dispose();
    transactionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: CommonAppBar(title: "Invoice Details", isBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.green,
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
                    child: Icon(Icons.payment, color: Colors.green, size: 42),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.invoice.invoice?.amount ?? "",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    capitalizeEachWord(widget.invoice.invoice?.category ?? ""),
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
                      widget.invoice.status ?? "",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.calendar_today_outlined,
                    title: "Payment Date",
                    value: DateFormatter.formatDateTime(
                      widget.invoice.invoice?.createdAt ?? DateTime.now(),
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),

                  _buildInfoRow(
                    icon: Icons.tag_outlined,
                    title: "Transaction ID",
                    value: widget.invoice.invoiceId.toString(),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),

                  _buildInfoRow(
                    icon: Icons.notes_outlined,
                    title: "Description",
                    value:
                        (widget.invoice.invoice?.description
                                    ?.trim()
                                    .isNotEmpty ??
                                false)
                            ? widget.invoice.invoice!.description!
                            : "No description avaliable",
                    maxLines: 4,
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
                          iconData: const Icon(Icons.attach_money),
                          hintText: 'Amount',
                          controller: amountController,
                          borderRadius: 8,
                        ),
                        const SizedBox(height: 10),

                        CustomDatePicker(
                          label: "Payment Date",
                          dateController: paymentDateController,
                          onDateSelected: (selectedDate) {
                            paymentDateController.text = DateFormat(
                              'yyyy-MM-dd',
                            ).format(selectedDate);
                          },
                        ),

                        const SizedBox(height: 10),

                        CustomTextfield(
                          iconData: const Icon(Icons.receipt_long),
                          hintText: 'Transaction ID',
                          controller: transactionController,
                          borderRadius: 8,
                        ),

                        const SizedBox(height: 20),
                        CustomDropdown(
                          dropdownKey: 'paymentMethod',
                          label: 'Select method',
                          icon: LucideIcons.creditCard,
                          items: const [
                            "cash",
                            "bank_transfer",
                            "upi",
                            "credit_card",
                            "debit_card",
                            "wallet",
                          ],
                          onChanged: (String? value) {
                            setState(() {
                              selectedMethod = value;
                            });
                          },
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
                              final amount =
                                  double.parse(
                                    amountController.text.trim(),
                                  ).toInt();

                              context
                                  .read<PaymentProvider>()
                                  .uploadPaymentDetails(
                                    context: context,
                                    studentId: widget.invoice.studentId ?? 0,
                                    invoiceStudentId: widget.invoice.id ?? 0,
                                    amount: amount,
                                    paymentDate:
                                        paymentDateController.text.trim(),
                                    paymentType:
                                        widget.invoice.invoice?.category ?? "",
                                    transactionId:
                                        transactionController.text.trim(),
                                    paymentMethod: selectedMethod ?? "",
                                    paymentAttachment: selectedFile,
                                  );
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    int maxLines = 2,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.green, size: 20),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
