import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parents/data/models/transport_invoice_model.dart';
import 'package:acadobs/features/parents/presentation/provider/transport_payment_provider.dart';
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

void showCreateTransportPaymentBottomSheet({
  required BuildContext context,
  required TransportInvoice invoice,
}) {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController(
    text: invoice.amount?.toString() ?? '',
  );
  final TextEditingController transactionIdController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  context.read<DropdownProvider>().setSelectedItem(
    'transportPaymentMethod',
    "UPI",
  );
  context.read<FilePickerProvider>().clearFile('transportPaymentAttachment');
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    "Create Transport Payment",
                    style: context.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Invoice brief info chip
                if (invoice.stop?.stopName != null || invoice.term != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (invoice.stop?.stopName != null)
                          Row(
                            children: [
                              const Icon(
                                LucideIcons.bus,
                                size: 16,
                                color: Color(0xFF00AEF0),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                invoice.stop!.stopName!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        if (invoice.term != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF00AEF0,
                              ).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              invoice.term!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0077A8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                SizedBox(height: Responsive.height * 1.5),

                CustomTextfield(
                  iconData: const Icon(LucideIcons.indianRupee),
                  controller: amountController,
                  hintText: 'Payment Amount*',
                  keyBoardtype: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
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
                      'yyyy-MM-dd',
                    ).format(selectedDate);
                  },
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),

                SizedBox(height: Responsive.height * 1),

                CustomTextfield(
                  iconData: const Icon(LucideIcons.fileText),
                  controller: transactionIdController,
                  hintText: 'Transaction ID',
                ),

                SizedBox(height: Responsive.height * 1),

                CustomDropdown(
                  dropdownKey: "transportPaymentMethod",
                  label: "Payment Method",
                  icon: LucideIcons.clipboardList,
                  items: AppConstants.paymentMethods,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please select a method'
                              : null,
                ),

                SizedBox(height: Responsive.height * 1.5),

                CustomFilePicker(
                  label: "Upload File* (Max 5 MB):",
                  fieldName: "transportPaymentAttachment",
                  validator: (value) {
                    final provider = context.read<FilePickerProvider>();
                    final error = provider.getError(
                      "transportPaymentAttachment",
                    );
                    if (error != null) return error;

                    if (provider.getFile("transportPaymentAttachment") ==
                        null) {
                      return "Please upload a payment attachment";
                    }
                    return null;
                  },
                ),

                SizedBox(height: Responsive.height * 3),

                Consumer<TransportPaymentProvider>(
                  builder: (context, provider, _) {
                    return CommonButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final selectedPaymentMethod = context
                              .read<DropdownProvider>()
                              .getSelectedItem('transportPaymentMethod');

                          final paymentMethod =
                              {
                                'Cash': 'cash',
                                'Bank Transfer': 'bank_transfer',
                                'UPI': 'upi',
                                'Credit Card': 'credit_card',
                                'Debit Card': 'debit_card',
                                'Wallet': 'wallet',
                              }[selectedPaymentMethod] ??
                              'bank_transfer';

                          final amount = double.tryParse(amountController.text);
                          if (amount == null) return;

                          provider.createTransportPayment(
                            context: context,
                            studentId: invoice.studentId ?? 0,
                            transportInvoiceId: invoice.id ?? 0,
                            amount: amount,
                            paymentDate: dateController.text,
                            transactionId: transactionIdController.text.trim(),
                            paymentMethod: paymentMethod,
                          );
                        }
                      },
                      widget:
                          provider.isLoadingUpload
                              ? const ButtonLoading()
                              : const Text(
                                'Upload & Submit Payment',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
