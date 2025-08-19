import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/providers/subject_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_filepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:acadobs/shared/widgets/students_picker.dart';
import 'package:acadobs/shared/widgets/subject_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

void showCreateHomeworkBottomSheet({required BuildContext context}) {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  context.read<SharedProvider>().clearSelectedClassId();
  context.read<DropdownProvider>().clearSelectedItem('homeworkType');
  context.read<DropdownProvider>().clearSelectedItem('standard');
  context.read<DropdownProvider>().clearSelectedItem('className');
  context.read<FilePickerProvider>().clearFile('homeworkFile');
  context.read<SubjectProvider>().clearSelection();
  context.read<StudentProvider>().deselectAllStudents();

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
                CustomDropdown(
                  dropdownKey: 'standard',
                  label: 'Select Standard*',
                  icon: LucideIcons.layers,
                  items: AppConstants.classGrades,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please select a class standard'
                              : null,
                  onChanged: (standard) {
                    context.read<SharedProvider>().getClassNameFromStandard(
                      context: context,
                      standard: int.parse(standard),
                    );
                  },
                ),
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
                                // className = selectedClass;
                                final selectedId =
                                    classMapList.firstWhere(
                                      (item) =>
                                          item['classname'] == selectedClass,
                                      orElse: () => {'id': null},
                                    )['id'];
                                provider.setClassId(selectedId);
                              },
                            ),
                          );
                    }
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                SubjectPicker(),
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
                  items: AppConstants.homeworkTypes,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please select type'
                              : null,
                ),
                SizedBox(height: Responsive.height * 1),
                Consumer2<StudentProvider, SharedProvider>(
                  builder: (context, studentProvider, sharedProvider, _) {
                    return StudentsPicker(classId: sharedProvider.classId ?? 0);
                  },
                ),
                SizedBox(height: Responsive.height * 2),
                CustomFilePicker(
                  label: "Upload File (Max 5 mb):",
                  fieldName: "homeworkFile",
                ),
                SizedBox(height: Responsive.height * 4),
                Consumer<HomeworkProvider>(
                  builder: (context, provider, _) {
                    final classId = context.watch<SharedProvider>().classId;
                    final subject =
                        context.watch<SubjectProvider>().selectedSubject;
                    return CommonButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          final homeworkType = context
                              .read<DropdownProvider>()
                              .getSelectedItem('homeworkType');
                          log(homeworkType);
                          context.read<HomeworkProvider>().createHomework(
                            context: context,
                            classId: classId ?? 0,
                            title: titleController.text,
                            description: descriptionController.text,
                            dueDate: dueDateController.text,
                            subjectId: subject?.id ?? 0,
                            type: homeworkType,
                          );
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
