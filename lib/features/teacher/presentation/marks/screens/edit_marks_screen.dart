import 'dart:developer';

import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/marks/marks_model.dart';
import 'package:acadobs/features/teacher/presentation/marks/provider/marks_provider.dart';
import 'package:acadobs/features/teacher/presentation/marks/widgets/editable_grade_card.dart';
import 'package:acadobs/shared/providers/subject_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/custom_datepicker.dart';
import 'package:acadobs/shared/widgets/custom_textfield.dart';
import 'package:acadobs/shared/widgets/subject_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class EditMarksScreen extends StatefulWidget {
  final MarksModel marks;

  const EditMarksScreen({super.key, required this.marks});

  @override
  State<EditMarksScreen> createState() => _EditMarksScreenState();
}

class _EditMarksScreenState extends State<EditMarksScreen> {
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
    dateController.text = DateFormat(
      'yyyy-MM-dd',
    ).format(widget.marks.date ?? DateTime.now());
    totalMarksController.text = widget.marks.maxMarks;
    subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
    marksProvider = context.read<MarksProvider>();
    marksProvider.fetchSingleMarks(marksId: widget.marks.id).then((_) {
      final students = marksProvider.singleMarks?.studentMarks ?? [];
      for (var i = 0; i < students.length; i++) {
        final student = students[i];
        _marksControllers[i] = TextEditingController(
          text: student.marksObtained ?? "0",
        );
        _statusMap[i] = student.status ?? "present";
      }
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      subjectProvider.setSubjectSelected(widget.marks.subject?.id ?? 0);
    });
  }

  void submitEditedMarks(BuildContext context) {
    final students = marksProvider.singleMarks?.studentMarks ?? [];
    final List<Map<String, dynamic>> updatedMarks = [];

    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final controller = _marksControllers[i];
      final text = controller?.text.trim() ?? '';
      final formatted = double.tryParse(text)?.toStringAsFixed(0) ?? text;
      final hasMarks = text.isNotEmpty;

      final marks = hasMarks ? int.tryParse(text) : 0;
      final status = hasMarks ? (_statusMap[i] ?? "present") : "absent";

      log("Student ID: ${student.student?.id}");
      log("Entered Marks: '$text' → Parsed: $marks");
      log("Status: $status");

      updatedMarks.add({
        "student_id": student.student?.id,
        "marks_obtained": formatted,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Details:",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: Responsive.height * 2),
                  SubjectPicker(),
                  SizedBox(height: Responsive.height * 2),
                  CustomTextfield(
                    iconData: Icon(LucideIcons.fileText),
                    controller: titleController,
                    hintText: 'Title',
                    label: "Title",
                  ),
                  SizedBox(height: Responsive.height * 2),
                  CustomTextfield(
                    iconData: Icon(Icons.calculate_outlined),
                    controller: totalMarksController,
                    keyBoardtype: TextInputType.number,
                    hintText: 'Total Marks*',
                    label: "Total Marks",
                  ),
                  SizedBox(height: Responsive.height * 2),
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
                  ),
                  SizedBox(height: Responsive.height * 2),
                  Consumer<SubjectProvider>(
                    builder: (context, subjectProvider, _) {
                      final selectedSubject = subjectProvider.selectedSubject;
                      return SizedBox(
                        height: Responsive.height * 6,
                        width: Responsive.width * 35,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(2),
                          ),
                          onPressed: () {
                            context.read<MarksProvider>().editMarksDetails(
                              context: context,
                              marksId: widget.marks.id,
                              title: titleController.text,
                              totalMarks: double.parse(
                                totalMarksController.text,
                              ),
                              date: dateController.text,
                              subjectId: selectedSubject?.id ?? 0,
                            );
                          },
                          child:
                              context.watch<MarksProvider>().isLoadingTwo
                                  ? ButtonLoading()
                                  : Text("Save"),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: Responsive.height * 4),
                  Text(
                    "Edit Student Marks:",
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: Responsive.height * 2),
                  Consumer<MarksProvider>(
                    builder: (context, provider, _) {
                      final students = provider.singleMarks?.studentMarks ?? [];

                      if (provider.isLoading || students.isEmpty) {
                        return commonShimmerList();
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final controller = _marksControllers[index]!;
                          final status = _statusMap[index] ?? "present";
                          final totalMarks = double.parse(
                            widget.marks.maxMarks,
                          );

                          return EditableGradeCard(
                            studentId: student.student?.id ?? 0,
                            name: student.student?.fullName ?? "",
                            rollNumber: student.student?.rollNumber ?? 0,
                            marksController: controller,
                            status: status,
                            totalMarks: double.parse(totalMarks.toString()),
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
                  SizedBox(height: Responsive.height * 4),
                  CommonButton(
                    onPressed: () {
                      submitEditedMarks(context);
                    },
                    widget: Text("Submit"),
                  ),
                  SizedBox(height: Responsive.height * 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
