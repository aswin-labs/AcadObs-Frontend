import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/marks/data/models/marks_upload_model.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/subjects/presentation/provider/subject_provider.dart';
import 'package:acadobs/features/subjects/presentation/widgets/subject_picker.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

void showAddMarksBottomSheet({required BuildContext context}) {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController totalMarksController = TextEditingController();
  dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
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
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFCE7F3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.clipboardCheck,
                      color: Color(0xFFBE185D),
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Add Class Test Marks",
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE7F3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFBCFE8)),
                  ),
                  child: const Text(
                    "Unit Tests • Chapter Tests • Weekly Tests",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9D174D),
                    ),
                  ),
                ),
                SizedBox(height: Responsive.height * 2.5),
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
                    final standardValue = switch (standard) {
                      'LKG' => -2,
                      'UKG' => -1,
                      _ => int.parse(standard),
                    };

                    context.read<SharedProvider>().getClassNameFromStandard(
                      context: context,
                      standard: standardValue,
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
                  hintText: 'Test Name (e.g. Unit Test 1, Chapter Test)*',
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
                Consumer<MarksProvider>(
                  builder: (context, provider, _) {
                    final classId = context.watch<SharedProvider>().classId;
                    final subject =
                        context.watch<SubjectProvider>().selectedSubject;

                    return CommonButton(
                      onPressed:
                          provider.isCheckingInternal
                              ? null
                              : () async {
                                if (!formKey.currentState!.validate()) return;

                                final className = context
                                    .read<DropdownProvider>()
                                    .getSelectedItem('className');

                                final markExists = await provider
                                    .checkExistingTermMarks(
                                      classId: classId ?? 0,
                                      subjectId: subject?.id ?? 0,
                                      title: titleController.text.trim(),
                                      date: dateController.text,
                                    );

                                if (!context.mounted) return;

                                if (markExists) {
                                  CustomSnackbar.show(
                                    context,
                                    message: 'Mark already exists',
                                    type: SnackbarType.failure,
                                  );
                                  return;
                                }

                                Navigator.pop(context);

                                context.pushNamed(
                                  RouteConstants.addStudentMarks,
                                  extra: MarksUploadModel(
                                    classId: classId ?? 0,
                                    className: className,
                                    subjectId: subject?.id ?? 0,
                                    title: titleController.text.trim(),
                                    totalMarks: int.parse(
                                      totalMarksController.text.trim(),
                                    ),
                                    date: dateController.text,
                                  ),
                                );
                              },
                      widget:
                          provider.isCheckingInternal
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
