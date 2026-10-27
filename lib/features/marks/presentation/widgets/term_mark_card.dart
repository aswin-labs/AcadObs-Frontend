import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/marks/data/models/marks_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class TermMarkCard extends StatelessWidget {
  final MarksModel mark;
  final VoidCallback onTap;

  const TermMarkCard({
    super.key,
    required this.mark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSpecial = mark.classGrade?.special == true;
    final className = mark.classGrade?.classname ?? '';
    final subjectName = mark.subject?.subjectName ?? '';
    final examName = mark.termExam?.examName ?? '';
    final educationYear = mark.termExam?.educationYear ?? '';
    final internalName = mark.internalName;
    final maxMarks = mark.maxMarks;
    final studentsCount = mark.studentMarks?.length ?? 0;
    final recordedByName = mark.user?.name;
    final isTermExam = mark.isTermExam || examName.isNotEmpty;

    final String displaySubject = isSpecial
        ? (className.isNotEmpty ? className : "Special Class")
        : (subjectName.isNotEmpty
            ? subjectName
            : (className.isNotEmpty ? className : "Subject"));

    final String displaySubtitle = internalName.isNotEmpty
        ? internalName
        : (isTermExam ? "Term Exam Marks" : "Class Test Marks");

    String? formattedDate;
    if (mark.date != null) {
      formattedDate = DateFormat('dd MMM yyyy').format(mark.date!);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Exam / Assessment Badge & Max Marks
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Pill
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isTermExam
                              ? theme.primaryColor.withAlpha(20)
                              : const Color(0xFFFCE7F3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isTermExam
                                ? theme.primaryColor.withAlpha(45)
                                : const Color(0xFFFBCFE8),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isTermExam
                                  ? LucideIcons.notebookTabs
                                  : LucideIcons.clipboardList,
                              size: 13,
                              color: isTermExam
                                  ? theme.primaryColor
                                  : const Color(0xFF9D174D),
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                examName.isNotEmpty
                                    ? (educationYear.isNotEmpty
                                        ? "$examName • $educationYear"
                                        : examName)
                                    : (isTermExam
                                        ? "Term Exam"
                                        : "Class Test"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: isTermExam
                                      ? theme.primaryColor
                                      : const Color(0xFF9D174D),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Max Marks Badge
                    if (maxMarks.isNotEmpty && maxMarks != "0")
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.target,
                              size: 12,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Max: $maxMarks",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Main Subject & Title Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isTermExam
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFCEDE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          isTermExam
                              ? LucideIcons.bookOpen
                              : LucideIcons.clipboardList,
                          size: 22,
                          color: isTermExam
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFFB14F6F),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Subject & Assessment Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitali(displaySubject),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            capitali(displaySubtitle),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Bottom Metadata Chips (Class, Students Count, Recorded By, Date)
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (className.isNotEmpty &&
                        (!isSpecial || subjectName.isNotEmpty))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.school,
                              size: 12,
                              color: Color(0xFF1D4ED8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Class $className",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (studentsCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFF3E8FF),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.users,
                              size: 12,
                              color: Color(0xFF7E22CE),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "$studentsCount Students",
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF7E22CE),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (recordedByName != null && recordedByName.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.user,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              recordedByName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (formattedDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.calendar,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
