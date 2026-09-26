import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/students/data/models/student_competency_assessment_model.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class StudentCompetencyScreen extends StatefulWidget {
  final int studentId;
  final bool forStaff;

  const StudentCompetencyScreen({
    super.key,
    required this.studentId,
    required this.forStaff,
  });

  @override
  State<StudentCompetencyScreen> createState() =>
      _StudentCompetencyScreenState();
}

class _StudentCompetencyScreenState extends State<StudentCompetencyScreen> {
  int? _selectedExamId; // null = All Terms (Grouped View)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    await context.read<StudentProvider>().fetchCompetencyAssessment(
      studentId: widget.studentId,
      forStaff: widget.forStaff,
    );
  }

  static const List<String> _ratingLabels = [
    'Not Rated',
    'Emerging',
    'Developing',
    'Proficient',
    'Exemplary',
  ];

  static const List<Color> _ratingColors = [
    Colors.grey,
    Color(0xFFE57373), // soft red
    Color(0xFFFFB74D), // orange
    Color(0xFF4FC3F7), // sky blue
    Color(0xFF81C784), // green
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CommonAppBar(title: "Competency Assessment", isBackButton: true),
      body: Consumer<StudentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingCompetency &&
              provider.groupedCompetencies.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: commonShimmerList(),
            );
          }

          if (provider.groupedCompetencies.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  emptyScreen(
                    message:
                        "No competency assessments available for this student.",
                  ),
                ],
              ),
            );
          }

          final rawItems = provider.competencyAssessments;
          final grouped = provider.groupedCompetencies;
          final exams = provider.competencyExams;

          final studentName =
              rawItems.isNotEmpty &&
                      rawItems.first.student?.fullName.isNotEmpty == true
                  ? rawItems.first.student!.fullName
                  : provider.individualStudent?.fullName ?? 'Student';
          final rollNumber =
              rawItems.isNotEmpty && rawItems.first.student?.rollNumber != null
                  ? rawItems.first.student!.rollNumber
                  : provider.individualStudent?.rollNumber;
          final academicYear =
              rawItems.isNotEmpty && rawItems.first.exam?.educationYear != null
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
                  competencyCount: grouped.length,
                  examCount: exams.length,
                ),

                // Rating Scale Legend
                const SizedBox(height: 14),

                // Term Filter Chips
                if (exams.isNotEmpty) ...[
                  _buildTermSelector(exams),
                  const SizedBox(height: 14),
                ],

                // Competencies List
                ...grouped.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final competency = entry.value;
                  return _buildCompetencyCard(index, competency, exams);
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
    required int competencyCount,
    required int examCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C3E50), Color(0xFF4834D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4834D4).withAlpha(60),
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
                icon: LucideIcons.layoutGrid,
                label: "Competencies",
                value: "$competencyCount",
              ),
              Container(width: 1, height: 28, color: Colors.white24),
              _buildStatColumn(
                icon: LucideIcons.calendarCheck,
                label: "Terms Evaluated",
                value: "$examCount",
              ),
              Container(width: 1, height: 28, color: Colors.white24),
              _buildStatColumn(
                icon: LucideIcons.sparkles,
                label: "View Mode",
                value: _selectedExamId == null ? "Grouped" : "Single Term",
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

  Widget _buildTermSelector(List<StudentCompetencyExamInfo> exams) {
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
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4834D4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4834D4) : Colors.grey.shade300,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: const Color(0xFF4834D4).withAlpha(50),
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
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompetencyCard(
    int number,
    GroupedCompetency competency,
    List<StudentCompetencyExamInfo> allExams,
  ) {
    final avgRating = competency.averageRating;
    final int roundedAvg = avgRating.round().clamp(0, 4);

    final String displayTitle = competency.title;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4834D4).withAlpha(18),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4834D4).withAlpha(60),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                "$number",
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4834D4),
                ),
              ),
            ),
          ),
          title: Text(
            displayTitle,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color:
                  roundedAvg > 0
                      ? _ratingColors[roundedAvg].withAlpha(30)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (roundedAvg > 0) ...[
                  Icon(
                    Icons.star_rounded,
                    size: 14,
                    color: _ratingColors[roundedAvg],
                  ),
                  const SizedBox(width: 3),
                  Text(
                    avgRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: _ratingColors[roundedAvg],
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ],
            ),
          ),
          children:
              competency.indicators.asMap().entries.map((indEntry) {
                final indIndex = indEntry.key + 1;
                final indicator = indEntry.value;
                return _buildIndicatorItem(
                  number,
                  indIndex,
                  indicator,
                  allExams,
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildIndicatorItem(
    int compNumber,
    int indNumber,
    GroupedIndicator indicator,
    List<StudentCompetencyExamInfo> allExams,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4834D4).withAlpha(15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "$compNumber.$indNumber",
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4834D4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  indicator.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Assessment Content: All Terms (Grouped) OR Single Term
          if (_selectedExamId == null)
            _buildGroupedTermsView(indicator, allExams)
          else
            _buildSingleTermView(indicator, _selectedExamId!),
        ],
      ),
    );
  }

  /// Displays Term 1, Term 2, etc. grouped together for the indicator
  Widget _buildGroupedTermsView(
    GroupedIndicator indicator,
    List<StudentCompetencyExamInfo> allExams,
  ) {
    if (allExams.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid/Row of Terms
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              allExams.map((exam) {
                final assessment = indicator.getAssessmentForExam(exam.id);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _buildTermAssessmentBox(
                      examName: exam.examName,
                      assessment: assessment,
                    ),
                  ),
                );
              }).toList(),
        ),

        // If both Term 1 and Term 2 are present, display a subtle progress indicator
        if (allExams.length >= 2) ...[_buildProgressTrend(indicator, allExams)],
      ],
    );
  }

  Widget _buildProgressTrend(
    GroupedIndicator indicator,
    List<StudentCompetencyExamInfo> allExams,
  ) {
    final term1 = indicator.getAssessmentForExam(allExams[0].id);
    final term2 = indicator.getAssessmentForExam(allExams[1].id);

    if (term1 == null ||
        term2 == null ||
        term1.rating == 0 ||
        term2.rating == 0) {
      return const SizedBox.shrink();
    }

    final diff = term2.rating - term1.rating;
    String trendText;
    Color trendColor;
    IconData trendIcon;

    if (diff > 0) {
      trendText =
          diff == 1
              ? "Progress: Improved (+1 Star)"
              : "Progress: Improved (+$diff Stars)";
      trendColor = Colors.green;
      trendIcon = LucideIcons.trendingUp;
    } else if (diff == 0) {
      trendText = "Consistent Performance";
      trendColor = Colors.blueGrey;
      trendIcon = LucideIcons.checkCheck;
    } else {
      trendText = "Needs Support";
      trendColor = Colors.orange;
      trendIcon = LucideIcons.trendingDown;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 4.0),
      child: Row(
        children: [
          Icon(trendIcon, size: 12, color: trendColor),
          const SizedBox(width: 4),
          Text(
            trendText,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: trendColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Individual Term Box in grouped view
  Widget _buildTermAssessmentBox({
    required String examName,
    required StudentCompetencyAssessmentItem? assessment,
  }) {
    final rating = assessment?.rating ?? 0;
    final validRating = rating.clamp(0, 4);
    final remarks = assessment?.remarks ?? '';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              validRating > 0
                  ? _ratingColors[validRating].withAlpha(60)
                  : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Term Label Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF4834D4).withAlpha(15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              examName,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4834D4),
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Rating Stars (4 stars)
          _buildRatingStars(validRating, starSize: 17),
          const SizedBox(height: 4),

          // Rating Text Label
          if (validRating > 0)
            Text(
              _ratingLabels[validRating],
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: _ratingColors[validRating],
              ),
            )
          else
            Text(
              "Not Evaluated",
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),

          // Remarks if available
          if (remarks.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4834D4).withAlpha(10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.messageSquareQuote,
                    size: 11,
                    color: Color(0xFF4834D4),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      remarks,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Displays single selected term's assessment
  Widget _buildSingleTermView(GroupedIndicator indicator, int examId) {
    final assessment = indicator.getAssessmentForExam(examId);
    final rating = assessment?.rating ?? 0;
    final validRating = rating.clamp(0, 4);
    final remarks = assessment?.remarks ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              validRating > 0
                  ? _ratingColors[validRating].withAlpha(60)
                  : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRatingStars(validRating, starSize: 22),
              if (validRating > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _ratingColors[validRating].withAlpha(25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _ratingLabels[validRating],
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: _ratingColors[validRating],
                    ),
                  ),
                ),
            ],
          ),
          if (remarks.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4834D4).withAlpha(10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    LucideIcons.messageSquareQuote,
                    size: 13,
                    color: Color(0xFF4834D4),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      remarks,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingStars(int rating, {double starSize = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        final starNumber = index + 1;
        final isFilled = starNumber <= rating;

        return Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isFilled ? const Color(0xFFFFB300) : Colors.grey.shade300,
            size: starSize,
          ),
        );
      }),
    );
  }
}
