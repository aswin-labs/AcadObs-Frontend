import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/marks/presentation/widgets/grade_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> showAddMissingStudentMarksDialog({
  required BuildContext context,
  required int internalId,
  required int classId,
  required double totalMarks,
  required List<int> alreadyAddedStudentIds,
}) async {
  final marksProvider = context.read<MarksProvider>();

  await marksProvider.fetchMissingStudents(
    classId: classId,
    studentIds: alreadyAddedStudentIds,
  );

  if (!context.mounted) return;

  final students = marksProvider.missingStudents;

  if (students.isEmpty) {
    CustomSnackbar.show(
      context,
      message: 'No new students found',
      type: SnackbarType.failure,
    );
    return;
  }

  final Map<int, TextEditingController> marksControllers = {
    for (final student in students) student.id: TextEditingController(),
  };

  final Map<int, String> statusMap = {
    for (final student in students) student.id: 'present',
  };

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            titlePadding: const EdgeInsets.fromLTRB(20, 20, 12, 10),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            actionsPadding: const EdgeInsets.all(16),

            title: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add New Student Marks',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            content: SizedBox(
              width: 550,
              height: MediaQuery.sizeOf(context).height * .65,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${students.length} new students',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Total: $totalMarks',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: ListView.separated(
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final student = students[index];

                        return GradeCard(
                          totalMarks: totalMarks.toInt(),
                          studentId: student.id,
                          marksController: marksControllers[student.id]!,
                          name: student.fullName,
                          rollNumber: student.rollNumber ?? 0,
                          status: statusMap[student.id] ?? 'present',
                          onStatusChanged: (newStatus) {
                            setDialogState(() {
                              statusMap[student.id] = newStatus;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),

              Consumer<MarksProvider>(
                builder: (context, provider, _) {
                  return ElevatedButton(
                    onPressed:
                        provider.isAddingMissingStudentMarks
                            ? null
                            : () async {
                              final studentMarks =
                                  students.map((student) {
                                    final controller =
                                        marksControllers[student.id]!;

                                    final text = controller.text.trim();

                                    final status =
                                        statusMap[student.id] ?? 'present';

                                    final marks =
                                        status == 'absent'
                                            ? 0.0
                                            : double.tryParse(text) ?? 0.0;

                                    return {
                                      "student_id": student.id,
                                      "marks_obtained": marks,
                                      "status": status,
                                    };
                                  }).toList();

                              final success = await provider
                                  .createNewMarksByInternalId(
                                    context: dialogContext,
                                    internalId: internalId,
                                    studentMarks: studentMarks,
                                  );

                              if (!dialogContext.mounted) {
                                return;
                              }

                              if (success) {
                                Navigator.pop(dialogContext);
                              }
                            },
                    child:
                        provider.isAddingMissingStudentMarks
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Submit Marks'),
                  );
                },
              ),
            ],
          );
        },
      );
    },
  );

  for (final controller in marksControllers.values) {
    controller.dispose();
  }
}
