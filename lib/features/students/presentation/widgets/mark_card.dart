import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/features/marks/data/models/student_mark_model.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class MarkCard extends StatelessWidget {
  final String subject;
  final String examtitle;
  final double mark;
  final double total;
  final bool isTermExam;
  final String? status;
  final String? date;
  final String? teacherName;
  final VoidCallback? onTap;

  const MarkCard({
    super.key,
    required this.examtitle,
    required this.subject,
    required this.mark,
    required this.total,
    this.isTermExam = false,
    this.status,
    this.date,
    this.teacherName,
    this.onTap,
  });

  factory MarkCard.fromStudentMark({
    Key? key,
    required StudentMarkModel studentMark,
    bool? isTermExam,
    VoidCallback? onTap,
  }) {
    final title = studentMark.examDisplayTitle;
    final subjectName = studentMark.internalExam?.subject?.subjectName ?? "N/A";
    final markObtained = studentMark.obtainedMarks;
    final totalMark = studentMark.maxMarks;

    String? formattedDate;
    if (studentMark.internalExam?.date != null) {
      formattedDate = DateFormatter.formatDateTime(
        studentMark.internalExam!.date!,
      );
    }

    final teacher = studentMark.internalExam?.user?.name;

    return MarkCard(
      key: key,
      examtitle: title,
      subject: subjectName,
      mark: markObtained,
      total: totalMark,
      isTermExam: isTermExam ?? studentMark.isTermExam,
      status: studentMark.status,
      date: formattedDate,
      teacherName: teacher,
      onTap: onTap,
    );
  }

  String _formatScore(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  Color _getScoreColor(double percentage) {
    if (percentage >= 75) {
      return const Color(0xFF10B981); // Emerald Green
    } else if (percentage >= 40) {
      return const Color(0xFFF59E0B); // Amber
    } else {
      return const Color(0xFFEF4444); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = total > 0 ? (mark / total) * 100 : 0.0;
    final Color scoreColor = _getScoreColor(percentage);

    // Differentiated theme colors for Term Exam vs Internal Mark
    final Color primaryAccent =
        isTermExam ? const Color(0xFF4F46E5) : const Color(0xFF0D9488);
    final Color badgeBg =
        isTermExam ? const Color(0xFFEEF2FF) : const Color(0xFFF0FDFA);
    final Color badgeBorder =
        isTermExam ? const Color(0xFFC7D2FE) : const Color(0xFF99F6E4);
    final Color cardBorder =
        isTermExam ? const Color(0xFFE0E7FF) : const Color(0xFFE2E8F0);
    final IconData typeIcon =
        isTermExam ? LucideIcons.award : LucideIcons.fileText;
    final String typeLabel = isTermExam ? "TERM EXAM" : "INTERNAL MARK";

    final bool isAbsent = status?.trim().toLowerCase() == 'absent';
    final bool isPresent = status?.trim().toLowerCase() == 'present';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: (isTermExam ? const Color(0xFF4F46E5) : Colors.black)
                      .withAlpha(isTermExam ? 15 : 10),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top colored accent strip
                  // Container(
                  //   height: 3.5,
                  //   width: double.infinity,
                  //   decoration: BoxDecoration(
                  //     gradient: LinearGradient(
                  //       colors: isTermExam
                  //           ? [const Color(0xFF4F46E5), const Color(0xFF818CF8)]
                  //           : [const Color(0xFF0D9488), const Color(0xFF2DD4BF)],
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Row: Badge (Type) + Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Exam Type Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: badgeBorder,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    typeIcon,
                                    size: 13,
                                    color: primaryAccent,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    typeLabel,
                                    style: TextStyle(
                                      color: primaryAccent,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Attendance status badge if present
                            if (status != null && status!.trim().isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isAbsent
                                          ? const Color(0xFFFEF2F2)
                                          : isPresent
                                          ? const Color(0xFFECFDF5)
                                          : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color:
                                        isAbsent
                                            ? const Color(0xFFFECACA)
                                            : isPresent
                                            ? const Color(0xFFA7F3D0)
                                            : const Color(0xFFE2E8F0),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  capitalizeEachWord(status!),
                                  style: TextStyle(
                                    color:
                                        isAbsent
                                            ? const Color(0xFFDC2626)
                                            : isPresent
                                            ? const Color(0xFF059669)
                                            : const Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Title ("exam_name - internal_name" or "internal_name")
                        Text(
                          capitalizeEachWord(examtitle),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F5F9),
                          ),
                        ),

                        // Subject & Marks Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Subject Icon Box
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    isTermExam
                                        ? const Color(0xFFEEF2FF)
                                        : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                LucideIcons.bookOpen,
                                size: 20,
                                color:
                                    isTermExam
                                        ? const Color(0xFF6366F1)
                                        : const Color(0xFF059669),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Subject Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    capitalizeEachWord(subject),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),

                                  // Date & Teacher Name metadata
                                  Wrap(
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    spacing: 6,
                                    children: [
                                      if (date != null &&
                                          date!.trim().isNotEmpty)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              LucideIcons.calendar,
                                              size: 11.5,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            const SizedBox(width: 3.5),
                                            Text(
                                              date!,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      if (date != null &&
                                          date!.trim().isNotEmpty &&
                                          teacherName != null &&
                                          teacherName!.trim().isNotEmpty)
                                        const Text(
                                          '•',
                                          style: TextStyle(
                                            color: Color(0xFFCBD5E1),
                                            fontSize: 11,
                                          ),
                                        ),
                                      if (teacherName != null &&
                                          teacherName!.trim().isNotEmpty)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              LucideIcons.user,
                                              size: 11.5,
                                              color: Color(0xFF94A3B8),
                                            ),
                                            const SizedBox(width: 3.5),
                                            Text(
                                              capitalizeEachWord(teacherName!),
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                color: Color(0xFF64748B),
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Score & Percentage
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: _formatScore(mark),
                                        style: TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w800,
                                          color:
                                              isAbsent
                                                  ? const Color(0xFFDC2626)
                                                  : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' / ${_formatScore(total)}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isAbsent
                                            ? const Color(0xFFFEF2F2)
                                            : scoreColor.withAlpha(25),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isAbsent
                                        ? "ABSENT"
                                        : "${percentage.toStringAsFixed(0)}%",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          isAbsent
                                              ? const Color(0xFFDC2626)
                                              : scoreColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:
                                isAbsent
                                    ? 0.0
                                    : (total > 0
                                        ? (mark / total).clamp(0.0, 1.0)
                                        : 0.0),
                            minHeight: 4.5,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isAbsent ? const Color(0xFFFECACA) : scoreColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
