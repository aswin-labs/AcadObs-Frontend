import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RemoveStudentHomeworkDialog extends StatelessWidget {
  final int homeworkId;

  const RemoveStudentHomeworkDialog({super.key, required this.homeworkId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxHeight: 450, maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Remove Students',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<HomeworksProvider>(
                builder: (context, provider, _) {
                  final studentStatuses =
                      provider.singleHomework?.studentHomeworkStatus ?? [];

                  if (studentStatuses.isEmpty) {
                    return const Center(
                      child: Text(
                        'No students available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: studentStatuses.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final status = studentStatuses[index];
                      final studentName =
                          status.student?.fullName ?? 'Unknown Student';
                      final rollNum = status.student?.rollNumber;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        title: Text(
                          capitalizeEachWord(studentName),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle:
                            rollNum != null
                                ? Text(
                                  'Roll No: $rollNum',
                                  style: const TextStyle(fontSize: 12),
                                )
                                : null,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showConfirmationDialog(
                              context: context,
                              title: 'Remove Student',
                              content:
                                  'Are you sure you want to remove ${capitalizeEachWord(studentName)} from this homework?',
                              action: 'Remove',
                              onConfirm: () {
                                provider.deleteHomeWorkStudent(
                                  context: context,
                                  studentHomeworkId: status.id ?? 0,
                                  homeworkId: homeworkId,
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
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
