import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class SingleStudentPicker extends StatelessWidget {
  final int classId;
  final StudentModel? selectedStudent;
  final ValueChanged<StudentModel> onStudentSelected;
  final String? Function(StudentModel?)? validator;

  const SingleStudentPicker({
    super.key,
    required this.classId,
    required this.onStudentSelected,
    this.selectedStudent,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<StudentModel>(
      key: ValueKey('student_picker_${classId}_${selectedStudent?.id}'),
      initialValue: selectedStudent,
      validator:
          validator ??
          (val) => val == null ? 'Please select a student' : null,
      builder: (fieldState) {
        final hasError = fieldState.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                if (classId <= 0) {
                  CustomSnackbar.show(
                    context,
                    message: 'Please select Standard and Class first.',
                    type: SnackbarType.warning,
                  );
                  return;
                }
                showSingleStudentSelectionPopup(
                  context,
                  classId,
                  selectedStudent,
                  (student) {
                    fieldState.didChange(student);
                    onStudentSelected(student);
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color:
                        hasError
                            ? Theme.of(context).colorScheme.error
                            : Colors.grey,
                  ),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 14, left: 4),
                      child: Icon(
                        LucideIcons.user,
                        color:
                            hasError
                                ? Theme.of(context).colorScheme.error
                                : Colors.grey.shade700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        selectedStudent?.fullName ?? 'Select Student*',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              selectedStudent != null
                                  ? Colors.black87
                                  : Colors.black54,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ],
                ),
              ),
            ),
            if (hasError && fieldState.errorText != null)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 6),
                child: Text(
                  fieldState.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

Future<void> showSingleStudentSelectionPopup(
  BuildContext context,
  int classId,
  StudentModel? selectedStudent,
  ValueChanged<StudentModel> onStudentSelected,
) async {
  final provider = context.read<StudentProvider>();

  // fetch students for this class
  await provider.fetchStudentsByClassId(context: context, classId: classId);
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return Consumer<StudentProvider>(
        builder: (context, provider, _) {
          final students = provider.students;
          StudentModel? tempSelected = selectedStudent;

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: const Text(
                  "Select Student",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Divider(),
                    SizedBox(
                      height: 300,
                      width: 300,
                      child:
                          students.isEmpty
                              ? const Center(
                                child: Text(
                                  "No students found in this class.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54),
                                ),
                              )
                              : RadioGroup<int>(
                                groupValue: tempSelected?.id,
                                onChanged: (selectedId) {
                                  if (selectedId == null) return;
                                  final index = students.indexWhere(
                                    (s) => s.id == selectedId,
                                  );
                                  if (index == -1) return;
                                  final student = students[index];
                                  setState(() {
                                    tempSelected = student;
                                  });
                                  onStudentSelected(student);
                                },
                                child: ListView.builder(
                                  itemCount: students.length,
                                  itemBuilder: (context, index) {
                                    final student = students[index];

                                    return RadioListTile<int>(
                                      title: Text(student.fullName),
                                      value: student.id,
                                    );
                                  },
                                ),
                              ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(80, 40),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Done"),
                  ),
                ],
              );
            },
          );
        },
      );
    },
  );
}
