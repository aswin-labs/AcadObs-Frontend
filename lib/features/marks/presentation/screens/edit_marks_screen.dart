import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/marks/data/models/marks_model.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/marks/presentation/widgets/editable_grade_card.dart';
import 'package:acadobs/features/subjects/presentation/provider/subject_provider.dart';
import 'package:acadobs/features/subjects/presentation/widgets/subject_picker.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_dropdown.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class EditMarksScreen extends StatefulWidget {
  final MarksModel marks;

  const EditMarksScreen({super.key, required this.marks});

  @override
  State<EditMarksScreen> createState() => _EditMarksScreenState();
}

class _EditMarksScreenState extends State<EditMarksScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SubjectProvider subjectProvider;
  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController totalMarksController = TextEditingController();
  late MarksProvider marksProvider;
  final Map<int, TextEditingController> _marksControllers = {};
  final Map<int, String> _statusMap = {};

  @override
  void initState() {
    super.initState();
    titleController.text = widget.marks.internalName;
    final existingTermExamName = widget.marks.internalName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (AppConstants.termExamNames.contains(existingTermExamName)) {
        context.read<DropdownProvider>().setSelectedItem(
          'termExamName',
          existingTermExamName,
        );
      }

      subjectProvider.clearSelection();
    });

    dateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(widget.marks.date ?? DateTime.now());
    totalMarksController.text = widget.marks.maxMarks;
    subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    marksProvider = context.read<MarksProvider>();

    final students = widget.marks.studentMarks ?? [];

    for (var i = 0; i < students.length; i++) {
      final student = students[i];

      _marksControllers[i] = TextEditingController(
        text: student.marksObtained ?? "0",
      );

      _statusMap[i] = student.status ?? "present";
    }
  }

  void submitEditedMarks(BuildContext context) {
    final students = widget.marks.studentMarks ?? [];
    final List<Map<String, dynamic>> updatedMarks = [];

    final totalMarks = double.tryParse(totalMarksController.text) ?? 0;

    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final controller = _marksControllers[i];
      final text = controller?.text.trim() ?? '';

      if (text.isEmpty) continue;

      final enteredMarks = double.tryParse(text) ?? 0.0;

      if (enteredMarks > totalMarks) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "${student.student?.fullName ?? "Student"}'s marks cannot exceed $totalMarks",
            ),
          ),
        );
        return; // Stop submission
      }
      final status = _statusMap[i] ?? "present";
      updatedMarks.add({
        "student_id": student.student?.id,
        "marks_obtained": enteredMarks,
        "status": status,
      });
    }

    marksProvider.editStudentMarks(
      context: context,
      marksId: widget.marks.id,
      editedMarks: updatedMarks,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Edit Marks", isBackButton: true),
      body: CustomScrollView(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showEditDetailsDialog(context),
                        icon: const Icon(Icons.edit_note),
                        label: const Text("Edit Mark Details"),
                      ),
                    ),
                    SizedBox(height: Responsive.height * 2),
                    Consumer<MarksProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoadingForSingleMarks) {
                          return commonShimmerList();
                        }

                        final students =
                            provider.singleMarks?.studentMarks ?? [];

                        if (students.isEmpty) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text("No student marks available"),
                            ),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            final controller = _marksControllers[index];
                            final status = _statusMap[index] ?? "present";
                            final totalMarks =
                                double.tryParse(widget.marks.maxMarks) ?? 0;

                            if (controller == null) {
                              return const SizedBox.shrink();
                            }

                            return EditableGradeCard(
                              studentId: student.student?.id ?? 0,
                              name: student.student?.fullName ?? "",
                              rollNumber: student.student?.rollNumber ?? 0,
                              marksController: controller,
                              status: status,
                              totalMarks: totalMarks,
                              onStatusChanged: (newStatus) {
                                setState(() {
                                  _statusMap[index] = newStatus;
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                    SizedBox(height: Responsive.height * 15),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: CommonButton(
          onPressed: () => submitEditedMarks(context),
          widget: Text("Save Marks"),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<void> _showEditDetailsDialog(BuildContext context) async {
    final detailsFormKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_note),
              SizedBox(width: 8),
              Text("Edit Details"),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Form(
              key: detailsFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SubjectPicker(
                      initialSubject: widget.marks.subject,
                      isSubjectRequired: false,
                    ),
                    SizedBox(height: Responsive.height * 2),

                    widget.marks.termExam == null
                        ? CustomTextfield(
                          iconData: const Icon(LucideIcons.fileText),
                          controller: titleController,
                          hintText: 'Title*',
                          label: "Title*",
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Title is required";
                            }
                            return null;
                          },
                        )
                        : CustomDropdown(
                          dropdownKey: "termExamName",
                          label: "Select Term Exam Name*",
                          icon: LucideIcons.notebookTabs,
                          items: AppConstants.termExamNames,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please select a term exam name";
                            }
                            return null;
                          },
                          onChanged: (selectedTermExamName) {
                            context.read<DropdownProvider>().setSelectedItem(
                              "termExamName",
                              selectedTermExamName,
                            );
                          },
                        ),

                    SizedBox(height: Responsive.height * 2),

                    CustomTextfield(
                      iconData: const Icon(Icons.calculate_outlined),
                      controller: totalMarksController,
                      keyBoardtype: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      hintText: "Total Marks*",
                      label: "Total Marks*",
                      validator: (value) {
                        final totalMarks = double.tryParse(value?.trim() ?? "");

                        if (totalMarks == null || totalMarks <= 0) {
                          return "Enter valid total marks";
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: Responsive.height * 2),

                    CustomDatePicker(
                      label: "Date*",
                      dateController: dateController,
                      onDateSelected: (selectedDate) {
                        dateController.text = DateFormat(
                          "yyyy-MM-dd",
                        ).format(selectedDate);
                      },
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: widget.marks.date ?? DateTime.now(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            Consumer2<MarksProvider, SubjectProvider>(
              builder: (context, marksProvider, subjectProvider, _) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                      marksProvider.isLoadingForEditDetails
                          ? null
                          : () {
                            if (!(detailsFormKey.currentState?.validate() ??
                                false)) {
                              return;
                            }

                            final termExamName = context
                                .read<DropdownProvider>()
                                .getSelectedItem("termExamName");

                            marksProvider.editMarksDetails(
                              context: context,
                              marksId: widget.marks.id,
                              title:
                                  widget.marks.termExam == null
                                      ? titleController.text.trim()
                                      : termExamName,
                              totalMarks:
                                  double.tryParse(
                                    totalMarksController.text.trim(),
                                  ) ??
                                  0,
                              date: dateController.text,
                              subjectId:
                                  subjectProvider.selectedSubject?.id ??
                                  widget.marks.subject?.id,
                            );
                          },
                  child:
                      marksProvider.isLoadingForEditDetails
                          ? ButtonLoading()
                          : const Text("Save"),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
