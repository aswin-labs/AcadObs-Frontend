import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/marks/marks_upload_model.dart';
import 'package:acadobs/features/teacher/presentation/marks/provider/marks_provider.dart';
import 'package:acadobs/features/teacher/presentation/marks/widgets/grade_card.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddStudentMarksScreen extends StatefulWidget {
  final MarksUploadModel marks;
  const AddStudentMarksScreen({super.key, required this.marks});

  @override
  State<AddStudentMarksScreen> createState() => _AddStudentMarksScreenState();
}

class _AddStudentMarksScreenState extends State<AddStudentMarksScreen> {
  late SharedProvider studentProvider;
  late MarksProvider marksProvider;
  final Map<int, TextEditingController> _marksControllers = {};
  final Map<int, String> _statusMap = {};
  @override
  void initState() {
    super.initState();
    studentProvider = context.read<SharedProvider>();
    studentProvider.fetchStudentsByClassId(classId: widget.marks.classId).then((
      _,
    ) {
      final students = studentProvider.students;
      for (var i = 0; i < students.length; i++) {
        _marksControllers[i] = TextEditingController();
      }
      setState(() {});
    });
  }

  // submit button
  void submitMarks(BuildContext context) {
    marksProvider = context.read<MarksProvider>();
    marksProvider.addStudentMarks(
      context: context,
      classId: widget.marks.classId,
      title: widget.marks.title,
      date: widget.marks.date,
      subjectId: widget.marks.subjectId,
      totalMarks: widget.marks.totalMarks,
      studentMarks: getStudentsMarkList(),
    );
  }

  List<Map<String, dynamic>> getStudentsMarkList() {
    final students = studentProvider.students;
    List<Map<String, dynamic>> studentMarksList = [];

    for (var i = 0; i < students.length; i++) {
      final student = students[i];
      final controller = _marksControllers[i];
      final text = controller?.text.trim() ?? '';
      final hasMarks = text.isNotEmpty;

      final marks = hasMarks ? int.tryParse(text) ?? 0 : 0;
      final status = hasMarks ? (_statusMap[i] ?? "present") : "absent";

      studentMarksList.add({
        "student_id": student.id,
        "marks_obtained": marks,
        "status": status,
      });
    }
    return studentMarksList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: capitalizeEachWord(widget.marks.className),
        isBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: context.paddingHorizontal.add(
                    EdgeInsets.only(top: Responsive.height * 2),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Date: ${widget.marks.date}",
                            style: TextStyle(
                              color: Color(0xFF6F6F6F),
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 90),
                          Text(
                            'Total Mark: ${widget.marks.totalMarks}',
                            style: TextStyle(color: Color(0xFF6F6F6F)),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Consumer<SharedProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading && provider.students.isEmpty) {
                            return commonShimmerList();
                          }
                          if (provider.students.isEmpty) {
                            return emptyScreen(message: 'No Students Found.');
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: provider.students.length,
                            itemBuilder: (context, index) {
                              final student = provider.students[index];
                              final marksController =
                                  _marksControllers[index] ??
                                  TextEditingController();
                              _marksControllers[index] = marksController;
                              final status = _statusMap[index] ?? "present";
                              return GradeCard(
                                totalMarks: widget.marks.totalMarks,
                                studentId: student.id,
                                marksController: marksController,
                                name: student.fullName,
                                rollNumber: student.rollNumber ?? 0,
                                status: status,
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
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CommonFloatingActionButton(
        onPressed: () {
          submitMarks(context);
        },
        text: "Submit",
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
