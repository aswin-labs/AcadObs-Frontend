import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parents/data/models/invoice_model.dart';
import 'package:acadobs/features/parents/presentation/provider/payment_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

void showCreatePaymentBottomSheet({
  required BuildContext context,
  required InvoiceModel invoice,
  int? paymentId,
  String? transactionId,
  bool forEdit = false,
}) {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController(
    text: invoice.invoice?.amount?.toString() ?? '',
  );
  final transactionIdController = TextEditingController(text: transactionId);
  final TextEditingController dateController = TextEditingController();

  context.read<DropdownProvider>().setSelectedItem('paymentMethod', "UPI");
  context.read<FilePickerProvider>().clearFile('paymentAttachment');
  dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Create Payment",
                  style: context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.height * 1),
                CustomTextfield(
                  iconData: Icon(LucideIcons.fileText),
                  controller: amountController,
                  hintText: 'Payment Amount*',
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomDatePicker(
                  label: "Date",
                  dateController: dateController,
                  onDateSelected: (selectedDate) {
                    dateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(selectedDate);
                  },
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),

                SizedBox(height: Responsive.height * 1),
                CustomTextfield(
                  iconData: Icon(LucideIcons.fileText),
                  controller: transactionIdController,
                  hintText: 'Transaction ID',
                ),
                SizedBox(height: Responsive.height * 1),
                CustomDropdown(
                  dropdownKey: "paymentMethod",
                  label: "Payment Method",
                  icon: LucideIcons.clipboardList,
                  items: AppConstants.paymentMethods,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please select a method'
                              : null,
                ),
                SizedBox(height: Responsive.height * 2),
                CustomFilePicker(
                  label: "Upload File* (Max 5 MB):",
                  fieldName: "paymentAttachment",
                  validator: (value) {
                    final provider = context.read<FilePickerProvider>();

                    final error = provider.getError("paymentAttachment");
                    if (error != null) return error;

                    if (!forEdit &&
                        provider.getFile("paymentAttachment") == null) {
                      return "Please upload a file";
                    }

                    return null;
                  },
                ),
                SizedBox(height: Responsive.height * 4),
                Consumer<PaymentProvider>(
                  builder: (context, provider, _) {
                    return CommonButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final selectedPaymentMethod = context
                              .read<DropdownProvider>()
                              .getSelectedItem('paymentMethod');

                          final paymentMethod =
                              {
                                'Cash': 'cash',
                                'Bank Transfer': 'bank_transfer',
                                'UPI': 'upi',
                                'Credit Card': 'credit_card',
                                'Debit Card': 'debit_card',
                                'Wallet': 'wallet',
                              }[selectedPaymentMethod];

                          log(paymentMethod ?? '');

                          final amount = double.tryParse(amountController.text);

                          if (amount == null) {
                            return;
                          }
                          forEdit
                              ? context
                                  .read<PaymentProvider>()
                                  .editPaymentDetails(
                                    context: context,
                                    paymentId: paymentId ?? 0,
                                    studentId: invoice.studentId ?? 0,
                                    invoiceStudentId: invoice.id ?? 0,
                                    amount: amount,
                                    paymentDate: dateController.text,
                                    paymentType:
                                        invoice.invoice?.category ?? "other",
                                    transactionId:
                                        transactionIdController.text.isEmpty
                                            ? ""
                                            : transactionIdController.text,
                                    paymentMethod: paymentMethod ?? 'upi',
                                  )
                              : context
                                  .read<PaymentProvider>()
                                  .uploadPaymentDetails(
                                    context: context,
                                    studentId: invoice.studentId ?? 0,
                                    invoiceStudentId: invoice.id ?? 0,
                                    amount: amount,
                                    paymentDate: dateController.text,
                                    paymentType:
                                        invoice.invoice?.category ?? "other",
                                    transactionId:
                                        transactionIdController.text.isEmpty
                                            ? ""
                                            : transactionIdController.text,
                                    paymentMethod: paymentMethod ?? 'upi',
                                  );
                        }
                      },
                      widget:
                          (forEdit
                                  ? provider.isLoadingForEdit
                                  : provider.isLoadingForUpload)
                              ? const ButtonLoading()
                              : Text(forEdit ? 'Update Details' : 'Upload'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
