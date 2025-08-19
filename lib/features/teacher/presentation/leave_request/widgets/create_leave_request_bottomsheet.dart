import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/provider/teacher_leave_request_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

void showCreateLeaveRequesBottomSheet(
  BuildContext context, {
  bool fromTeacherScreen = true,
  int studentId = 0,
}) {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  context.read<DropdownProvider>().clearSelectedItem('leavetype');
  context.read<FilePickerProvider>().clearFile('attachment');
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
                  fromTeacherScreen ? "Teacher Leave" : "Student Leave",
                  style: context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.height * 3),
                CustomDatePicker(
                  label: "Start Date*",
                  dateController: fromDateController,
                  onDateSelected: (selectedDate) {
                    fromDateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(selectedDate);
                  },
                  firstDate: DateTime.now(),
                  lastDate: DateTime(
                    DateTime.now().year,
                    DateTime.now().month + 1,
                    DateTime.now().day,
                  ),
                  initialDate: DateTime.now(),
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomDatePicker(
                  label: "End Date*",
                  dateController: toDateController,
                  onDateSelected: (selectedDate) {
                    toDateController.text = DateFormat(
                      'dd/MM/yyyy',
                    ).format(selectedDate);
                  },
                  firstDate: DateTime.now(),
                  lastDate: DateTime(
                    DateTime.now().year,
                    DateTime.now().month + 1,
                    DateTime.now().day,
                  ),
                  initialDate: DateTime.now(),
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomTextfield(
                  iconData: Icon(LucideIcons.fileText),
                  controller: reasonController,
                  hintText: 'Reason for Leave*',
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomDropdown(
                  dropdownKey: "leavetype",
                  label: "Leave Type*",
                  icon: LucideIcons.clipboardList,
                  items: AppConstants.leaveTypes,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please select leave type'
                              : null,
                ),
                SizedBox(height: Responsive.height * 2),
                CustomFilePicker(
                  label: "Upload File (Max 5 mb):",
                  fieldName: "attachment",
                ),
                SizedBox(height: Responsive.height * 4),
                fromTeacherScreen
                    ? Consumer<TeacherLeaveRequestProvider>(
                      builder: (context, provider, _) {
                        return CommonButton(
                          onPressed: () {
                            final leaveType = context
                                .read<DropdownProvider>()
                                .getSelectedItem('leavetype');
                            if (formKey.currentState?.validate() ?? false) {
                              context
                                  .read<TeacherLeaveRequestProvider>()
                                  .createLeaveRequest(
                                    context: context,
                                    fromDate: fromDateController.text,
                                    toDate: toDateController.text,
                                    leaveType: leaveType,
                                    reason: reasonController.text,
                                  );
                            }
                          },
                          widget:
                              provider.isLoadingTwo
                                  ? ButtonLoading()
                                  : const Text('Submit'),
                        );
                      },
                    )
                    : Consumer<StudentLeaveRequestProvider>(
                      builder: (context, provider, _) {
                        return CommonButton(
                          onPressed: () {
                            final leaveType = context
                                .read<DropdownProvider>()
                                .getSelectedItem('leavetype');

                            context
                                .read<StudentLeaveRequestProvider>()
                                .createStudentLeaveRequest(
                                  context: context,
                                  fromDate: fromDateController.text,
                                  toDate: toDateController.text,
                                  leaveType: leaveType,
                                  reason: reasonController.text,
                                  studentId:studentId 
                                );
                          },

                          widget:
                              provider.isLoadingTwo
                                  ? ButtonLoading()
                                  : Text('Submit'),
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
