import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class SingleStudentPicker extends StatelessWidget {
  final int classId;
  final StudentModel? selectedStudent;
  final ValueChanged<StudentModel> onStudentSelected;

  const SingleStudentPicker({
    super.key,
    required this.classId,
    required this.onStudentSelected,
    this.selectedStudent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showSingleStudentSelectionPopup(
        context,
        classId,
        selectedStudent,
        onStudentSelected,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 15, left: 2),
              child: Icon(LucideIcons.user, color: Colors.grey),
            ),
            Expanded(
              child: Text(
                selectedStudent?.fullName ?? 'Select Student',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
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
    builder: (context) {
      return Consumer<StudentProvider>(
        builder: (context, provider, _) {
          final students = provider.students;

          return AlertDialog(
            title: const Text("Select Student"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(),
                SizedBox(
                  height: 320,
                  width: 300,
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];

                      return RadioListTile<int>(
                        title: Text(student.fullName),
                        value: student.id,
                        groupValue: selectedStudent?.id,
                        onChanged: (_) {
                          onStudentSelected(student); // update only this section
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ],
          );
        },
      );
    },
  );
}
