// import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';

import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class StudentPickerManage extends StatelessWidget {
  final int classId;
  final bool selectAllNeeded;
  final Function(List<int>)? onStudentsSelected;
  const StudentPickerManage({
    super.key,
    required this.classId,
    this.selectAllNeeded = true,
    this.onStudentsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => showStudentSelectionPopup(
            context,
            classId,
            selectAllNeeded: selectAllNeeded,
            onDone: () {
              onStudentsSelected?.call(context.read<StudentProvider>().selectedStudentIds.toList());
            },
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
              child: Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  final selectedId = provider.selectedStudentIds;
                  final students = provider.students;

                  String displayText;

                  if (selectedId.isEmpty) {
                    displayText = 'Manage Students';
                  } else if (selectedId.length == 1) {
                    final student =
                        students.isNotEmpty
                            ? students.firstWhere(
                              (s) => s.id == selectedId.first,
                              orElse: () => students.first,
                            )
                            : null;

                    if (student != null) {
                      displayText = student.fullName;
                    } else {
                      displayText = "Manage Students";
                    }
                  } else {
                    displayText = "${selectedId.length} students selected";
                  }

                  return Text(
                    displayText,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  );
                },
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
  Function()? onDone,
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
                  onDone?.call();
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
