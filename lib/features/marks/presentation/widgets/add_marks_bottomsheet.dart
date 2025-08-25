import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/marks/data/models/marks_upload_model.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/providers/subject_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:acadobs/shared/widgets/subject_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

void showAddMarksBottomSheet({required BuildContext context}) {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController totalMarksController = TextEditingController();
  context.read<SharedProvider>().clearSelectedClassId();
  context.read<DropdownProvider>().clearSelectedItem('standard');
  context.read<DropdownProvider>().clearSelectedItem('className');
  context.read<SubjectProvider>().clearSelection();

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
                  "Add Marks",
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
                  hintText: 'Title*',
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomTextfield(
                  iconData: Icon(Icons.calculate_outlined),
                  controller: totalMarksController,
                  keyBoardtype: TextInputType.number,
                  hintText: 'Total Marks*',
                  validator: (value) {
                    return FormValidator.validateNotEmpty(value);
                  },
                ),
                SizedBox(height: Responsive.height * 1),
                CustomDatePicker(
                  label: "Date*",
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

                SizedBox(height: Responsive.height * 4),
                Consumer<HomeworkProvider>(
                  builder: (context, provider, _) {
                    final classId = context.watch<SharedProvider>().classId;
                    final subject =
                        context.watch<SubjectProvider>().selectedSubject;

                    return CommonButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final className = context
                              .read<DropdownProvider>()
                              .getSelectedItem('className');
                          context.pushNamed(
                            RouteConstants.addStudentMarks,
                            extra: MarksUploadModel(
                              classId: classId ?? 0,
                              className: className,
                              subjectId: subject?.id ?? 0,
                              title: titleController.text,
                              totalMarks: int.parse(totalMarksController.text),
                              date: dateController.text,
                            ),
                          );
                          Navigator.pop(context);
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
