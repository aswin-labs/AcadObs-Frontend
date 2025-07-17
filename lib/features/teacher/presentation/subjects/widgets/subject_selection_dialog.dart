import 'package:acadobs/features/teacher/presentation/subjects/provider/subject_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showSubjectSelectionDialog(BuildContext context) async {
  final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
  await subjectProvider.fetchSubjects();
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('Select Subject'),
        content: Consumer<SubjectProvider>(
          builder: (context, subjectProvider, _) {
            if (subjectProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (subjectProvider.schoolSubjects.isEmpty) {
              return Text("No subjects found.");
            }

            return SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: subjectProvider.schoolSubjects.length,
                itemBuilder: (context, index) {
                  final subject = subjectProvider.schoolSubjects[index];
                  final isSelected =
                      subjectProvider.selectedSubject?.id == subject.id;

                  return ListTile(
                    title: Text(subject.subjectName),
                    trailing:
                        isSelected
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : null,
                    tileColor: isSelected ? Colors.green.shade50 : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onTap: () {
                      subjectProvider.selectSubject(subject);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            );
          },
        ),
      );
    },
  );
}
