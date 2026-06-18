import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/features/subjects/presentation/provider/subject_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubjectPicker extends StatelessWidget {
  final bool? isSubjectRequired;
  const SubjectPicker({super.key, this.isSubjectRequired = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectProvider>(
      builder: (context, subjectProvider, _) {
        return GestureDetector(
          onTap: () => showSubjectSelectionDialog(context),
          child: AbsorbPointer(
            child: TextFormField(
              style: context.textTheme.bodyMedium,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 15.0,
                ),
                labelText: isSubjectRequired == true ? 'Subject*' : 'Subject',

                prefixIcon: Icon(Icons.book),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              controller: TextEditingController(
                text:
                    subjectProvider.selectedSubject?.subjectName ??
                    'Select Subject',
              ),
              validator:
                  (value) =>
                      subjectProvider.selectedSubject == null &&
                              isSubjectRequired == true
                          ? 'Please select a subject'
                          : null,
            ),
          ),
        );
      },
    );
  }
}

Future<void> showSubjectSelectionDialog(BuildContext context) async {
  final subjectProvider = Provider.of<SubjectProvider>(context, listen: false);
  await subjectProvider.fetchAllSubjects();
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('Select Subject*'),
        content: Consumer<SubjectProvider>(
          builder: (context, subjectProvider, _) {
            if (subjectProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            }
            if (subjectProvider.subjectsAll.isEmpty) {
              return Text("No subjects found.");
            }

            return SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: subjectProvider.subjectsAll.length,
                itemBuilder: (context, index) {
                  final subject = subjectProvider.subjectsAll[index];
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
