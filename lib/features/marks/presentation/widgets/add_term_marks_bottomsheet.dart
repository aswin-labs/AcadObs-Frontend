import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/form_validators.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/marks/data/models/marks_upload_model.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
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

Future<void> showAddTermMarksBottomSheet({
  required BuildContext context,
}) async {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController totalMarksController = TextEditingController();

  int? selectedTermExamId;
  String? selectedTermExamName;

  final termExamProvider = context.read<TermExamProvider>();

  if (termExamProvider.termExams.isEmpty) {
    await termExamProvider.fetchTermExams();
  }

  if (!context.mounted) return;
  dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  context.read<SharedProvider>().clearSelectedClassId();
  context.read<DropdownProvider>().clearSelectedItem('standard');
  context.read<DropdownProvider>().clearSelectedItem('className');
  context.read<DropdownProvider>().clearSelectedItem('termExam');
  context.read<DropdownProvider>().clearSelectedItem('termExamName');
  context.read<SubjectProvider>().clearSelection();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
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
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          LucideIcons.notebookTabs,
                          color: Theme.of(context).primaryColor,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Add Term Exam Marks",
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
                        color: Theme.of(context).primaryColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withAlpha(50),
                        ),
                      ),
                      child: Text(
                        "Official Term & Semester Examination",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.height * 2.5),
                    Consumer<TermExamProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingExams) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (provider.termExams.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'No term exams available',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: Colors.red,
                              ),
                            ),
                          );
                        }

                        final examLabels =
                            provider.termExams.map((exam) {
                              final examName =
                                  exam['exam_name']?.toString() ?? '';
                              final educationYear =
                                  exam['education_year']?.toString() ?? '';

                              return '$examName - $educationYear';
                            }).toList();

                        return CustomDropdown(
                          dropdownKey: 'termExam',
                          label: 'Select Term Exam*',
                          icon: LucideIcons.notebookTabs,
                          items: examLabels,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a term exam';
                            }

                            return null;
                          },
                          onChanged: (selectedLabel) {
                            final selectedExam = provider.termExams.firstWhere((
                              exam,
                            ) {
                              final examName =
                                  exam['exam_name']?.toString() ?? '';
                              final educationYear =
                                  exam['education_year']?.toString() ?? '';
                              final label = '$examName - $educationYear';

                              return label == selectedLabel;
                            });

                            setModalState(() {
                              selectedTermExamId = selectedExam['id'] as int?;
                              selectedTermExamName =
                                  selectedExam['exam_name']?.toString();
                            });
                          },
                        );
                      },
                    ),

                    SizedBox(height: Responsive.height * 1),

                    CustomDropdown(
                      dropdownKey: "termExamName",
                      label: "Select Term Exam Name*",
                      icon: LucideIcons.notebookTabs,
                      items: AppConstants.termExamNames,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a term exam name';
                        }
                        return null;
                      },
                      onChanged: (selectedTermExamName) {
                        context.read<DropdownProvider>().setSelectedItem(
                          'termExamName',
                          selectedTermExamName,
                        );
                      },
                    ),
                    SizedBox(height: Responsive.height * 1),
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
                                              item['classname'] ==
                                              selectedClass,
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
                    Consumer<TermExamProvider>(
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

                                    if (selectedTermExamId == null) {
                                      CustomSnackbar.show(
                                        context,
                                        message: 'Please select a term exam',
                                        type: SnackbarType.failure,
                                      );
                                      return;
                                    }

                                    final className = context
                                        .read<DropdownProvider>()
                                        .getSelectedItem('className');

                                    final termExamName = context
                                        .read<DropdownProvider>()
                                        .getSelectedItem('termExamName');

                                    final markExists = await provider
                                        .checkExistingTermMarks(
                                          classId: classId!,
                                          subjectId: subject!.id,
                                          title: termExamName,
                                          date: dateController.text,
                                          termExamId: selectedTermExamId!,
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
                                        isTermExam: true,
                                        term: selectedTermExamName ?? '',
                                        termExamId: selectedTermExamId!,
                                        classId: classId,
                                        className: className,
                                        subjectId: subject.id,
                                        title: termExamName,
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
    },
  );
}
