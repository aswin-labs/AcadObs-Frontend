import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/marks/marks_upload_model.dart';
import 'package:acadobs/features/teacher/presentation/marks/provider/marks_provider.dart';
import 'package:acadobs/features/teacher/presentation/marks/widgets/grade_card.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
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
  @override
  void initState() {
    studentProvider = context.read<SharedProvider>();
    studentProvider.fetchStudentsByClassId(classId: widget.marks.classId);
    super.initState();
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
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: provider.students.length,
                            itemBuilder: (context, index) {
                              final student = provider.students[index];
                              return GradeCard(
                                studentId: student.id,
                                name: student.fullName,
                                rollNumber: student.rollNumber ?? 0,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              child: CommonButton(
                onPressed: () {
                  // log('submit');
                  final marks = widget.marks;
                  context.read<MarksProvider>().addStudentMarks(
                    context: context,
                    classId: marks.classId,
                    title: marks.title,
                    date: marks.date,
                    subjectId: marks.subjectId,
                    totalMarks: marks.totalMarks,
                  );
                },
                widget: Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
