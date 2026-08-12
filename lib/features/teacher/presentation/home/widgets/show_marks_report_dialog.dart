import 'dart:developer';
import 'dart:typed_data';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/pdf_saver_service.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/marks/presentation/provider/term_exam_provider.dart';
import 'package:acadobs/features/teacher/data/services/my_class_services.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

Future<void> showMarksReportDialog({
  required BuildContext context,
  required int classId,
  required String className,
}) async {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int? selectedTermExamId;

  final termExamProvider = context.read<TermExamProvider>();

  if (termExamProvider.termExams.isEmpty) {
    await termExamProvider.fetchTermExams();
  }

  if (!context.mounted) return;

  context.read<DropdownProvider>().clearSelectedItem('marksReportTermExam');
  context.read<DropdownProvider>().clearSelectedItem('marksReportTermExamName');

  showDialog(
    context: context,
    builder: (context) {
      bool isDownloading = false;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                const Icon(LucideIcons.fileText, color: Color(0xFF5B42F3)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Marks Report ($className)",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<TermExamProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingExams) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (provider.termExams.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'No term exams available',
                              style: TextStyle(color: Colors.red, fontSize: 13),
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
                          dropdownKey: 'marksReportTermExam',
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

                            setDialogState(() {
                              selectedTermExamId = selectedExam['id'] as int?;
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: Responsive.height * 1.5),
                    CustomDropdown(
                      dropdownKey: 'marksReportTermExamName',
                      label: 'Select Exam Name*',
                      icon: LucideIcons.notebookTabs,
                      items: AppConstants.termExamNames,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an exam name';
                        }
                        return null;
                      },
                      onChanged: (selectedExamName) {
                        context.read<DropdownProvider>().setSelectedItem(
                          'marksReportTermExamName',
                          selectedExamName,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDownloading ? null : () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              Consumer<DropdownProvider>(
                builder: (context, dropdownProvider, _) {
                  return SizedBox(
                    width: 130,
                    child: CommonButton(
                      onPressed:
                          isDownloading
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

                                final internalName = dropdownProvider
                                    .getSelectedItem('marksReportTermExamName');

                                setDialogState(() {
                                  isDownloading = true;
                                });

                                try {
                                  final response = await MyClassServices()
                                      .getClassWiseTermMarksPdf(
                                        examId: selectedTermExamId!,
                                        internalName: internalName,
                                        classId: classId,
                                      );

                                  if (response.statusCode == 200 &&
                                      response.data != null) {
                                    final Uint8List bytes = Uint8List.fromList(
                                      List<int>.from(response.data),
                                    );

                                    await PdfSaverService.saveAndOpenPdf(
                                      bytes: bytes,
                                      fileName:
                                          'marks_report_${className}_$internalName.pdf',
                                    );

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      CustomSnackbar.show(
                                        context,
                                        message:
                                            'Marks report downloaded successfully',
                                        type: SnackbarType.success,
                                      );
                                    }
                                  } else {
                                    if (context.mounted) {
                                      CustomSnackbar.show(
                                        context,
                                        message:
                                            'Failed to download marks report',
                                        type: SnackbarType.failure,
                                      );
                                    }
                                  }
                                } catch (e) {
                                  log('Marks report download error');
                                  if (context.mounted) {
                                    CustomSnackbar.show(
                                      context,
                                      message: 'Error downloading marks report',
                                      type: SnackbarType.failure,
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setDialogState(() {
                                      isDownloading = false;
                                    });
                                  }
                                }
                              },
                      widget:
                          isDownloading
                              ? const ButtonLoading()
                              : const Text('Download'),
                    ),
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );
}
