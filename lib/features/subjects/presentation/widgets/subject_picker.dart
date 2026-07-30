import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/features/subjects/presentation/provider/subject_provider.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubjectPicker extends StatefulWidget {
  final bool? isSubjectRequired;
  final SubjectModel? initialSubject;

  const SubjectPicker({
    super.key,
    this.isSubjectRequired = true,
    this.initialSubject,
  });

  @override
  State<SubjectPicker> createState() => _SubjectPickerState();
}

class _SubjectPickerState extends State<SubjectPicker> {
  @override
  void initState() {
    super.initState();

    if (widget.initialSubject != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final provider = context.read<SubjectProvider>();

        if (provider.selectedSubject?.id != widget.initialSubject!.id) {
          provider.selectSubject(widget.initialSubject!);
        }
      });
    }
  }

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
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 15,
                ),
                labelText:
                    widget.isSubjectRequired == true ? 'Subject*' : 'Subject',
                prefixIcon: const Icon(Icons.book),
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
                  (_) =>
                      subjectProvider.selectedSubject == null &&
                              widget.isSubjectRequired == true
                          ? 'Please select a subject'
                          : null,
            ),
          ),
        );
      },
    );
  }

  Future<void> showSubjectSelectionDialog(BuildContext context) async {
    final subjectProvider = Provider.of<SubjectProvider>(
      context,
      listen: false,
    );
    await subjectProvider.fetchAllSubjects();
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
              if (subjectProvider.subjectsAll.isEmpty) {
                return Text("No subjects found.");
              }

              final itemCount = subjectProvider.subjectsAll.length;
              const itemHeight = 56.0;
              final maxHeight = MediaQuery.of(context).size.height * 0.6;
              final calculatedHeight = (itemCount * itemHeight).clamp(
                0.0,
                maxHeight,
              );

              return SizedBox(
                width: double.maxFinite,
                height: calculatedHeight,
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
}
