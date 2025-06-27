import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

void showAttendanceBottomSheet(BuildContext context) {
  final TextEditingController dateController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Set initial value to today's date
  dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Mark Attendance",
                  style: context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.height * 2),
                CustomDropdown(
                  dropdownKey: 'standard',
                  label: 'Select Standard',
                  icon: LucideIcons.school,
                  items: ['1', '2'],
                ),
                SizedBox(height: Responsive.height * 1),
                CustomDropdown(
                  dropdownKey: 'className',
                  label: 'Select Class',
                  icon: LucideIcons.school,
                  items: ['1', '2'],
                ),
                SizedBox(height: Responsive.height * 1),
                CustomDatePicker(
                  label: "Date*",
                  dateController: dateController,
                  onDateSelected: (selectedDate) {
                    dateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(selectedDate);
                  },
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Please select a date"
                              : null,
                ),
                SizedBox(height: Responsive.height * 1),
              ],
            ),
          ),
        ),
      );
    },
  );
}
