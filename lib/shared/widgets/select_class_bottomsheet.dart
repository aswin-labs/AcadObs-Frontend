import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void selectClassBottomsheet(BuildContext context) {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final dropdownProvider = context.read<DropdownProvider>();

  dropdownProvider.clearSelectedItem('class');
  dropdownProvider.clearSelectedItem('division');

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
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// **Title**
                Text(
                  "Select Class and Division",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),

                /// **Class Dropdown**
                CustomDropdown(
                  dropdownKey: 'class',
                  icon: Icons.school_outlined,
                  label: "Select Class Grade*",
                  items: AppConstants.classGrades,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Please select a class"
                              : null,
                ),
                SizedBox(height: 12),

                /// **Division Dropdown**
                CustomDropdown(
                  dropdownKey: 'division',
                  icon: Icons.access_time,
                  label: "Select Division*",
                  items: AppConstants.classGrades,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? "Please select a division"
                              : null,
                ),
                SizedBox(height: 16),
                CommonButton(onPressed: () {}, widget: Text("Add Student")),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    },
  );
}
