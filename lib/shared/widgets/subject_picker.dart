import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/features/teacher/presentation/subjects/provider/subject_provider.dart';
import 'package:acadobs/features/teacher/presentation/subjects/widgets/subject_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubjectPicker extends StatelessWidget {
  const SubjectPicker({super.key});

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
                labelText: 'Subject',

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
                      subjectProvider.selectedSubject == null
                          ? 'Please select a subject'
                          : null,
            ),
          ),
        );
      },
    );
  }
}
