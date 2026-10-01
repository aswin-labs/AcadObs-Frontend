import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/students/data/models/student_progress_report_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_protector/screen_protector.dart';

class StudentProgressCardScreen extends StatefulWidget {
  final int studentId;
  final bool forStaff;

  const StudentProgressCardScreen({
    super.key,
    required this.studentId,
    required this.forStaff,
  });

  @override
  State<StudentProgressCardScreen> createState() =>
      _StudentProgressCardScreenState();
}

class _StudentProgressCardScreenState extends State<StudentProgressCardScreen> {
  int? _selectedExamId; // null = All Terms (default)

  @override
  void initState() {
    super.initState();
    _enableScreenProtection();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _enableScreenProtection() async {
    try {
      if (!kIsWeb) {
        await ScreenProtector.preventScreenshotOn();
      }
    } catch (e) {
      log('Error enabling screen protection: $e');
    }
  }

  Future<void> _disableScreenProtection() async {
    try {
      if (!kIsWeb) {
        await ScreenProtector.preventScreenshotOff();
      }
    } catch (e) {
      log('Error disabling screen protection: $e');
    }
  }

  @override
  void dispose() {
    _disableScreenProtection();
    super.dispose();
  }

  Future<void> _loadData() async {
    await context.read<StudentProvider>().fetchProgressReport(
      studentId: widget.studentId,
      forStaff: widget.forStaff,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CommonAppBar(title: 'Progress Report', isBackButton: true),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingProgressReport &&
              provider.progressReport == null) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: commonShimmerList(),
            );
          }

          if (provider.progressReportError != null &&
              provider.progressReport == null) {
            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red.shade600,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Unable to load progress report',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.progressReportError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _loadData,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D9488),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final report = provider.progressReport;
          if (report == null || report.subjects.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  emptyScreen(
                    message:
                        "No progress report data available for this student.",
                  ),
                ],
              ),
            );
          }

          // Sort subjects by priority as given in response
          final sortedSubjects = List<ProgressReportSubject>.from(
            report.subjects,
          )..sort((a, b) => (a.priority ?? 999).compareTo(b.priority ?? 999));

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
              children: [
                // Confidential Security Notice
                // _buildSecurityBanner(),
                const SizedBox(height: 12),

                // Student Details Header
                _buildStudentHeader(report),

                const SizedBox(height: 14),

                // Term Filter Chips
                if (report.exams.length > 1) ...[
                  _buildTermSelector(report),
                  const SizedBox(height: 14),
                ],

                // Two-Level Grouped Table (matching requested design)
                _buildGroupedMarksTable(report, sortedSubjects),
              ],
            ),
          );
        },
      ),
    );
  }

  // Student header showing only response details
  Widget _buildStudentHeader(StudentProgressReportModel report) {
    final student = report.student;
    final studentName = student?.fullName ?? 'Student';
    final className = student?.className ?? '-';
    final rollNo = student?.rollNumber != null ? '${student!.rollNumber}' : '-';
    final academicYear = report.educationYear ?? '-';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Initial Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF0D9488), Color(0xFF0284C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D9488).withAlpha(60),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                studentName.isNotEmpty ? studentName[0].toUpperCase() : 'S',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _buildInfoBadge(
                      'Class $className',
                      const Color(0xFF0284C7),
                    ),
                    _buildInfoBadge('Roll #$rollNo', const Color(0xFF64748B)),
                    _buildInfoBadge(academicYear, const Color(0xFF0D9488)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // Term selector chips (All Terms, Term 1, Term 2)
  Widget _buildTermSelector(StudentProgressReportModel report) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildTermChip(
            label: 'All Terms',
            isSelected: _selectedExamId == null,
            onTap: () {
              setState(() {
                _selectedExamId = null;
              });
            },
          ),
          const SizedBox(width: 8),
          ...report.exams.map((exam) {
            final isSelected = _selectedExamId == exam.examId;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildTermChip(
                label: exam.examName ?? 'Exam',
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedExamId = exam.examId;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTermChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D9488) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF0D9488).withAlpha(50),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF334155),
          ),
        ),
      ),
    );
  }

  // TWO-LEVEL GROUPED TABLE (Term 1 -> PT, Internal | Term 2 -> PT)
  Widget _buildGroupedMarksTable(
    StudentProgressReportModel report,
    List<ProgressReportSubject> subjects,
  ) {
    // Filter exams by selected filter
    final visibleExams =
        _selectedExamId == null
            ? report.exams
            : report.exams.where((e) => e.examId == _selectedExamId).toList();

    // Map each visible exam to its columns
    final List<MapEntry<ProgressReportExam, List<ProgressReportColumn>>>
    examGroups = [];

    int totalAssessmentColumns = 0;
    for (final exam in visibleExams) {
      final cols =
          report.columns.where((c) => c.examId == exam.examId).toList();
      if (cols.isNotEmpty) {
        examGroups.add(MapEntry(exam, cols));
        totalAssessmentColumns += cols.length;
      }
    }

    if (totalAssessmentColumns == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No tests or exams recorded for this selection.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      );
    }

    const Color borderColor = Color(0xFFE5E7EB);
    const double subjectWidth = 135.0;
    const double baseColWidth = 110.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableWidth = constraints.maxWidth - subjectWidth;
        final double minScrollWidth = totalAssessmentColumns * baseColWidth;

        // If screen is wider than needed, expand columns to fill width; otherwise use baseColWidth
        double colWidth = baseColWidth;
        if (availableWidth > minScrollWidth) {
          colWidth = (availableWidth / totalAssessmentColumns).floorToDouble();
        }

        final double scrollableWidth =
            (availableWidth > minScrollWidth)
                ? (colWidth * totalAssessmentColumns)
                : minScrollWidth;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(5),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================
                // 1. FIXED LEFT COLUMN: Subject Header & Names
                // ============================================
                Container(
                  width: subjectWidth,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      right: BorderSide(color: borderColor, width: 1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Fixed "Subject" Header cell (height 74 to match two-level header)
                      Container(
                        height: 74,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text(
                          'Subject',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),

                      // Horizontal divider under header
                      Container(height: 1, color: borderColor),

                      // Fixed Subject rows (each height 52)
                      ...subjects.asMap().entries.map((subEntry) {
                        final sIdx = subEntry.key;
                        final subject = subEntry.value;
                        final isLastSubject = sIdx == subjects.length - 1;

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              height: 52,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                subject.subjectName ?? '',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isLastSubject)
                              Container(height: 1, color: borderColor),
                          ],
                        );
                      }),
                    ],
                  ),
                ),

                // ============================================
                // 2. HORIZONTALLY SCROLLABLE ASSESSMENT COLUMNS
                // ============================================
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: scrollableWidth,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header (Two-Level Grouped: Term 1, Term 2 -> Internals)
                          SizedBox(
                            height: 74,
                            child: Row(
                              children:
                                  examGroups.asMap().entries.map((entry) {
                                    final examIdx = entry.key;
                                    final exam = entry.value.key;
                                    final cols = entry.value.value;
                                    final isLastExam =
                                        examIdx == examGroups.length - 1;
                                    final double groupWidth =
                                        cols.length * colWidth;

                                    return SizedBox(
                                      width: groupWidth,
                                      height: 74,
                                      child: Column(
                                        children: [
                                          // Level 1: Term / Exam Name
                                          Container(
                                            width: groupWidth,
                                            height: 36,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border(
                                                bottom: const BorderSide(
                                                  color: borderColor,
                                                ),
                                                right:
                                                    isLastExam
                                                        ? BorderSide.none
                                                        : const BorderSide(
                                                          color: borderColor,
                                                        ),
                                              ),
                                            ),
                                            child: Text(
                                              exam.examName ?? 'Exam',
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111827),
                                              ),
                                            ),
                                          ),

                                          // Level 2: Sub-headers (PT, Internal, etc. with Max marks)
                                          SizedBox(
                                            height: 38,
                                            width: groupWidth,
                                            child: Row(
                                              children:
                                                  cols.asMap().entries.map((
                                                    colEntry,
                                                  ) {
                                                    final colIdx = colEntry.key;
                                                    final col = colEntry.value;
                                                    final isLastColInGroup =
                                                        colIdx ==
                                                        cols.length - 1;
                                                    final isVeryLastCol =
                                                        isLastExam &&
                                                        isLastColInGroup;

                                                    return Expanded(
                                                      child: Container(
                                                        height: 38,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            right:
                                                                isVeryLastCol
                                                                    ? BorderSide
                                                                        .none
                                                                    : const BorderSide(
                                                                      color:
                                                                          borderColor,
                                                                    ),
                                                          ),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              col.internalName ??
                                                                  'Test',
                                                              style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: Color(
                                                                  0xFF111827,
                                                                ),
                                                              ),
                                                            ),
                                                            if (col.maxMarks !=
                                                                    null &&
                                                                col
                                                                    .maxMarks!
                                                                    .isNotEmpty)
                                                              Text(
                                                                'Max: ${col.maxMarks}',
                                                                style: const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Color(
                                                                    0xFF6B7280,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),

                          // Horizontal divider under entire header
                          Container(height: 1, color: borderColor),

                          // Data Rows for Assessment Values
                          ...subjects.asMap().entries.map((subEntry) {
                            final sIdx = subEntry.key;
                            final subject = subEntry.value;
                            final isLastSubject = sIdx == subjects.length - 1;

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 52,
                                  child: Row(
                                    children:
                                        examGroups.asMap().entries.expand((
                                          egEntry,
                                        ) {
                                          final examIdx = egEntry.key;
                                          final cols = egEntry.value.value;
                                          final isLastExam =
                                              examIdx == examGroups.length - 1;

                                          return cols.asMap().entries.map((
                                            colEntry,
                                          ) {
                                            final colIdx = colEntry.key;
                                            final col = colEntry.value;
                                            final isVeryLastCol =
                                                isLastExam &&
                                                colIdx == cols.length - 1;

                                            final markEntry = subject
                                                .getMarkForColumn(col.key);

                                            return Container(
                                              width: colWidth,
                                              height: 52,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  right:
                                                      isVeryLastCol
                                                          ? BorderSide.none
                                                          : const BorderSide(
                                                            color: borderColor,
                                                          ),
                                                ),
                                              ),
                                              child: _buildDataCellContent(
                                                markEntry,
                                              ),
                                            );
                                          });
                                        }).toList(),
                                  ),
                                ),
                                if (!isLastSubject)
                                  Container(height: 1, color: borderColor),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Cell content: Marks (bold black), Absent (soft red pill), or — (grey dash)
  Widget _buildDataCellContent(ProgressReportMarkEntry? entry) {
    if (entry == null ||
        (entry.marksObtained == null && entry.status == null)) {
      return Text(
        '—',
        style: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (entry.isAbsent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Absent',
          style: TextStyle(
            color: Color(0xFFEF4444),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Text(
      entry.marksObtained ?? '0.00',
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.bold,
        color: Color(0xFF111827),
      ),
    );
  }
}
