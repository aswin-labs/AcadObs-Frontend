import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class StudentsPicker extends StatelessWidget {
  final int classId;
  final bool selectAllNeeded;
  const StudentsPicker({
    super.key,
    required this.classId,
    this.selectAllNeeded = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => showStudentSelectionPopup(
            context,
            classId,
            selectAllNeeded: selectAllNeeded,
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
            Padding(
              padding: const EdgeInsets.only(right: 15, left: 2),
              child: const Icon(LucideIcons.userCheck, color: Colors.grey),
            ),
            Expanded(
              child: Text(
                'Manage Students*',
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

Future<void> showStudentSelectionPopup(
  BuildContext context,
  int classId, {
  bool selectAllNeeded = true,
}) async {
  final provider = context.read<StudentProvider>();

  // Fetch students if not already done
  await provider.fetchStudentsByClassId(context: context, classId: classId);
  if (!context.mounted) return;
  showDialog(
    context: context,
    builder: (context) {
      return Consumer<StudentProvider>(
        builder: (context, provider, _) {
          final students = provider.students;

          return AlertDialog(
            title: const Text("Select Students"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                selectAllNeeded
                    ? Row(
                      children: [
                        Checkbox(
                          value: provider.isAllSelected,
                          onChanged: (_) {
                            if (provider.isAllSelected) {
                              provider.deselectAllStudents();
                            } else {
                              provider.selectAllStudents();
                            }
                          },
                        ),
                        const Text("Select All"),
                      ],
                    )
                    : SizedBox.shrink(),
                const Divider(),
                SizedBox(
                  height: 320, // scrollable height
                  width: 300,
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      final isSelected = provider.selectedStudentIds.contains(
                        student.id,
                      );

                      return CheckboxListTile(
                        title: Text(student.fullName), // or roll no etc.
                        value: isSelected,
                        onChanged:
                            (_) =>
                                selectAllNeeded
                                    ? provider.toggleStudentSelection(
                                      student.id,
                                    )
                                    : provider.toggleSingleStudentSelection(
                                      student.id,
                                    ),
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
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            ],
          );
        },
      );
    },
  );
}
