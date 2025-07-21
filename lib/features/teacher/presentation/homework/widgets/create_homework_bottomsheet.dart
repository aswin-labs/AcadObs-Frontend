import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/provider/teacher_leave_request_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

void showCreateHomeworkBottomSheet(BuildContext context) {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  context.read<DropdownProvider>().clearSelectedItem('homeworkType');
  // context.read<FilePickerProvider>().clearFile('attachment');
  int? classId;
  String? className;
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
                  "Add Homework",
                  style: context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: Responsive.height * 3),
                 Consumer<SharedProvider>(
                  builder: (context, provider, _) {
                    List<Map<String, dynamic>> classMapList =
                        provider.classNames;
                    List<String> onlyClassNames =
                        classMapList
                            .map((item) => item['classname'].toString())
                            .toList();
                    if (provider.isLoading) {
                      return CircularProgressIndicator();
                    } else if (provider.isClassesEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "No Classes Available",
                          style: context.textTheme.bodySmall!.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      );
                    } else {
                      return onlyClassNames.isEmpty
                          ? SizedBox.shrink()
                          : Padding(
                            padding: EdgeInsets.only(
                              top: Responsive.height * 1,
                            ),
                            child: CustomDropdown(
                              dropdownKey: 'className',
                              label: 'Select Class*',
                              icon: LucideIcons.school,
                              items: onlyClassNames,
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Please select a class'
                                          : null,
                              onChanged: (selectedClass) {
                                className = selectedClass;
                                classId =
                                    classMapList.firstWhere(
                                      (item) =>
                                          item['classname'] == selectedClass,
                                      orElse: () => {'id': null},
                                    )['id'];
                              },
                            ),
                          );
                    }
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomTextfield(
                  iconData: Icon(LucideIcons.fileText),
                  controller: titleController,
                  hintText: 'Homework Title*',
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomTextfield(
                  iconData: Icon(LucideIcons.fileText),
                  controller: descriptionController,
                  hintText: 'Description*',
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomDatePicker(
                  label: "Due Date*",
                  dateController: dueDateController,
                  onDateSelected: (selectedDate) {
                    dueDateController.text = DateFormat(
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
                CustomDropdown(
                  dropdownKey: "homeworkType",
                  label: "Homework Type",
                  icon: LucideIcons.clipboardList,
                  items: AppConstants.leaveTypes,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please select type'
                              : null,
                ),
                SizedBox(height: Responsive.height * 2),
                CustomFilePicker(
                  label: "Upload File (Max 5 mb):",
                  fieldName: "attachment",
                ),
                SizedBox(height: Responsive.height * 4),
                Consumer<TeacherLeaveRequestProvider>(
                  builder: (context, provider, _) {
                    return CommonButton(
                      onPressed: () {
                        final homeworkType = context
                            .read<DropdownProvider>()
                            .getSelectedItem('homeworkType');
                        if (formKey.currentState?.validate() ?? false) {
                        
                        }
                      },
                      widget:
                          provider.isLoadingTwo
                              ? ButtonLoading()
                              : const Text('Save'),
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
