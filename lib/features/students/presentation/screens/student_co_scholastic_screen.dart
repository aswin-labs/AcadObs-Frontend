import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/students/data/models/student_co_scholastic_assessment_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class StudentCoScholasticScreen extends StatefulWidget {
  final int studentId;
  final bool forStaff;

  const StudentCoScholasticScreen({
    super.key,
    required this.studentId,
    required this.forStaff,
  });

  @override
  State<StudentCoScholasticScreen> createState() =>
      _StudentCoScholasticScreenState();
}

class _StudentCoScholasticScreenState extends State<StudentCoScholasticScreen> {
  int? _selectedExamId; // null = All Terms (Grouped View)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<StudentProvider>().fetchCoScholasticAssessment(
          studentId: widget.studentId,
          forStaff: widget.forStaff,
        );
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final parsed = DateTime.parse(rawDate);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return "${parsed.day.toString().padLeft(2, '0')} ${months[parsed.month - 1]} ${parsed.year}";
    } catch (_) {
      return rawDate;
    }
  }

  Color _getGradeColor(String grade) {
    switch (grade.trim().toUpperCase()) {
      case 'A+':
        return const Color(0xFF00B894);
      case 'A':
        return const Color(0xFF00CEC9);
      case 'B+':
        return const Color(0xFF0984E3);
      case 'B':
        return const Color(0xFF6C5CE7);
      case 'C':
        return const Color(0xFFF39C12);
      case 'D':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getAreaIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('physical') ||
        lower.contains('sport') ||
        lower.contains('pe') ||
        lower.contains('fitness') ||
        lower.contains('yoga')) {
      return Icons.fitness_center_rounded;
    }
    if (lower.contains('art') ||
        lower.contains('craft') ||
        lower.contains('drawing')) {
      return Icons.palette_outlined;
    }
    if (lower.contains('music') ||
        lower.contains('sing') ||
        lower.contains('dance')) {
      return Icons.music_note_rounded;
    }
    if (lower.contains('attendance') ||
        lower.contains('punctual') ||
        lower.contains('discipline')) {
      return Icons.event_available_rounded;
    }
    if (lower.contains('work') || lower.contains('experience')) {
      return Icons.handyman_outlined;
    }
    if (lower.contains('health')) {
      return Icons.favorite_outline_rounded;
    }
    return Icons.stars_rounded;
  }

  Color _getAreaColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('physical') || lower.contains('sport')) {
      return const Color(0xFF00B894);
    }
    if (lower.contains('art')) {
      return const Color(0xFFE17055);
    }
    if (lower.contains('music')) {
      return const Color(0xFF6C5CE7);
    }
    if (lower.contains('attendance')) {
      return const Color(0xFF0984E3);
    }
    return const Color(0xFF0077B6);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(
        title: "Co-Scholastic Assessment",
        isBackButton: true,
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingCoScholastic &&
              provider.groupedCoScholasticAreas.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: commonShimmerList(),
            );
          }

          if (provider.groupedCoScholasticAreas.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  emptyScreen(
                    message:
                        "No co-scholastic assessments available for this student.",
                  ),
                ],
              ),
            );
          }

          final rawItems = provider.coScholasticAssessments;
          final grouped = provider.groupedCoScholasticAreas;
          final exams = provider.coScholasticExams;

          final studentName = rawItems.isNotEmpty &&
                  rawItems.first.student?.fullName.isNotEmpty == true
              ? rawItems.first.student!.fullName
              : provider.individualStudent?.fullName ?? 'Student';
          final rollNumber = rawItems.isNotEmpty &&
                  rawItems.first.student?.rollNumber != null
              ? rawItems.first.student!.rollNumber
              : provider.individualStudent?.rollNumber;
          final academicYear = rawItems.isNotEmpty &&
                  rawItems.first.exam?.educationYear != null
              ? rawItems.first.exam!.educationYear
              : null;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              children: [
                // Top Header Card
                _buildHeaderCard(
                  studentName: studentName,
                  rollNumber: rollNumber,
                  academicYear: academicYear,
                  areaCount: grouped.length,
                  examCount: exams.length,
                ),

                const SizedBox(height: 14),

                // Term Filter Chips
                if (exams.isNotEmpty) ...[
                  _buildTermSelector(exams),
                  const SizedBox(height: 14),
                ],

                // Co-Scholastic Areas List
                ...grouped.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final area = entry.value;
                  return _buildAreaCard(index, area, exams);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard({
    required String studentName,
    int? rollNumber,
    String? academicYear,
    required int areaCount,
    required int examCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0077B6), Color(0xFF0096C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0077B6).withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(45),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withAlpha(80),
                    width: 1.5,
                  ),
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (rollNumber != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Roll: $rollNumber",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (academicYear != null && academicYear.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(35),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              academicYear,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                icon: LucideIcons.shapes,
                label: "Areas",
                value: "$areaCount",
              ),
              Container(width: 1, height: 28, color: Colors.white24),
              _buildStatColumn(
                icon: LucideIcons.calendarCheck,
                label: "Terms Evaluated",
                value: "$examCount",
              ),
              Container(width: 1, height: 28, color: Colors.white24),
              _buildStatColumn(
                icon: LucideIcons.award,
                label: "View Mode",
                value: _selectedExamId == null ? "All Terms" : "Single Term",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white70),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTermSelector(List<StudentCoScholasticExamInfo> exams) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All Terms option (Grouped side-by-side view)
          _buildFilterChip(
            label: "All Terms (Grouped)",
            icon: LucideIcons.columns2,
            isSelected: _selectedExamId == null,
            onTap: () {
              setState(() {
                _selectedExamId = null;
              });
            },
          ),
          const SizedBox(width: 8),

          // Individual Term filters
          ...exams.map((exam) {
            final isSelected = _selectedExamId == exam.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: _buildFilterChip(
                label: exam.examName,
                icon: LucideIcons.calendar,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedExamId = exam.id;
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0077B6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0077B6)
                : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF0077B6).withAlpha(40),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaCard(
    int number,
    GroupedCoScholasticArea area,
    List<StudentCoScholasticExamInfo> allExams,
  ) {
    final areaColor = _getAreaColor(area.name);
    final areaIcon = _getAreaIcon(area.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Area Header
            Row(
              children: [
                // Area Number Badge
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: areaColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(areaIcon, size: 18, color: areaColor),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$number. ${area.name}",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (area.classGroup != null &&
                          area.classGroup!.isNotEmpty)
                        Text(
                          "Class Group: ${area.classGroup}",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Content: All Terms (Grouped) OR Single Selected Term
            if (_selectedExamId == null)
              _buildGroupedTermsView(area, allExams)
            else
              _buildSingleTermView(area, _selectedExamId!),
          ],
        ),
      ),
    );
  }

  /// Displays Term 1, Term 2, etc. grouped together for the co-scholastic area
  Widget _buildGroupedTermsView(
    GroupedCoScholasticArea area,
    List<StudentCoScholasticExamInfo> allExams,
  ) {
    if (allExams.isEmpty) return const SizedBox.shrink();

    final isAttendance = area.name.toLowerCase().contains('attendance');

    return Column(
      children: allExams.map((exam) {
        final assessment = area.getAssessmentForExam(exam.id);
        final hasGrade = assessment?.grade != null &&
            assessment!.grade!.trim().isNotEmpty;
        final hasScore = assessment?.score != null;
        final grade = assessment?.grade ?? '';
        final score = assessment?.score;
        final remarks = assessment?.remarks ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (hasGrade || hasScore)
                  ? Colors.blue.shade100
                  : Colors.grey.shade200,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Term title
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 13,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        exam.examName,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),

                  // Grade / Score Badge
                  if (hasGrade)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _getGradeColor(grade),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Grade $grade",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (hasScore)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0984E3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isAttendance ? "$score%" : "Score: $score",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Not Assessed",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                ],
              ),

              // Remarks (if any)
              if (remarks.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    remarks,
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],

              // Footer: Date & Recorder info
              if (assessment != null &&
                  (assessment.recorder?.name != null ||
                      (assessment.assessedAt != null &&
                          assessment.assessedAt!.isNotEmpty))) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      LucideIcons.userCheck,
                      size: 11,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Recorded on ${_formatDate(assessment.assessedAt)}${assessment.recorder?.name != null ? ' • by ${assessment.recorder!.name}' : ''}",
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Displays single selected term assessment details for this area
  Widget _buildSingleTermView(
    GroupedCoScholasticArea area,
    int examId,
  ) {
    final assessment = area.getAssessmentForExam(examId);
    final isAttendance = area.name.toLowerCase().contains('attendance');

    if (assessment == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            "No assessment recorded for this term",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ),
      );
    }

    final hasGrade =
        assessment.grade != null && assessment.grade!.trim().isNotEmpty;
    final hasScore = assessment.score != null;
    final grade = assessment.grade ?? '';
    final score = assessment.score;
    final remarks = assessment.remarks ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Grade & Score Row
          Row(
            children: [
              if (hasGrade)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getGradeColor(grade),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: _getGradeColor(grade).withAlpha(50),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Grade $grade",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              if (hasGrade && hasScore) const SizedBox(width: 8),
              if (hasScore)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0984E3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isAttendance ? "Attendance: $score%" : "Score: $score",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),

          // Remarks (if any)
          if (remarks.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.messageSquare,
                    size: 13,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      remarks,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Footer: Assessed Date & Recorder
          if (assessment.recorder?.name != null ||
              (assessment.assessedAt != null &&
                  assessment.assessedAt!.isNotEmpty)) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  LucideIcons.userCheck,
                  size: 12,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "Recorded on ${_formatDate(assessment.assessedAt)}${assessment.recorder?.name != null ? ' • by ${assessment.recorder!.name}' : ''}",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
