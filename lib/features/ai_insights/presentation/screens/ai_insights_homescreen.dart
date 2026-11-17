import 'package:acadobs/features/ai_insights/data/models/ai_student_skills_model.dart';
import 'package:acadobs/features/ai_insights/presentation/provider/ai_insights_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class AiInsightsHomescreen extends StatefulWidget {
  final int studentId;

  const AiInsightsHomescreen({super.key, required this.studentId});

  @override
  State<AiInsightsHomescreen> createState() => _AiInsightsHomescreenState();
}

class _AiInsightsHomescreenState extends State<AiInsightsHomescreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AiInsightsProvider>().fetchStudentAiInsights(
        studentId: widget.studentId,
      );
    });
  }

  String _formatNum(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    final parsed = DateTime.tryParse(rawDate);
    if (parsed == null) return rawDate;
    return DateFormat('dd MMM yyyy').format(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: CommonAppBar(title: 'AI Student Insights', isBackButton: true),
      body: Consumer<AiInsightsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.aiProfile == null) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF355872)),
                  SizedBox(height: 16),
                  Text(
                    'Analyzing student academic & skill profile...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          }

          if (provider.errorMessage != null && provider.aiProfile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Color(0xFFDC2626),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to Load AI Insights',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          provider.fetchStudentAiInsights(
                            studentId: widget.studentId,
                            forceRefresh: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF355872),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(LucideIcons.refreshCw, size: 16),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final profile = provider.aiProfile;
          if (profile == null) {
            return const SizedBox.shrink();
          }

          return RefreshIndicator(
            color: const Color(0xFF355872),
            onRefresh:
                () => provider.fetchStudentAiInsights(
                  studentId: widget.studentId,
                  forceRefresh: true,
                ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStudentHeroHeader(profile),
                  const SizedBox(height: 16),
                  _buildExploreSkillsBanner(context, profile),
                  const SizedBox(height: 12),
                  _buildCareerActionCard(context, profile),
                  const SizedBox(height: 24),

                  // 1. ACADEMIC PROFILE (1st Priority)
                  _buildSectionHeader(
                    icon: LucideIcons.graduationCap,
                    title: 'Academic Profile',
                    subtitle:
                        '${profile.academicProfile.totalAssessments} Assessments • ${_formatNum(profile.academicProfile.totalObtainedMarks)}/${_formatNum(profile.academicProfile.totalMaximumMarks)} Marks',
                    accentColor: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 12),
                  _buildAcademicProfileSection(profile.academicProfile),
                  const SizedBox(height: 24),

                  // 2. HOMEWORK PROFILE
                  _buildSectionHeader(
                    icon: LucideIcons.bookOpenCheck,
                    title: 'Homework Profile',
                    subtitle:
                        '${profile.homeworkProfile.totalAssignments} Assignments • Avg ${_formatNum(profile.homeworkProfile.averagePoints)}/5 pts',
                    accentColor: const Color(0xFF7C3AED),
                  ),
                  const SizedBox(height: 12),
                  _buildHomeworkProfileSection(profile.homeworkProfile),
                  const SizedBox(height: 24),

                  // 3. CO-SCHOLASTIC PROFILE
                  _buildSectionHeader(
                    icon: LucideIcons.medal,
                    title: 'Co-Scholastic Profile',
                    subtitle:
                        '${profile.coScholasticProfile.validAssessments} Assessments • Avg ${_formatNum(profile.coScholasticProfile.averageScore)}%',
                    accentColor: const Color(0xFF0D9488),
                  ),
                  const SizedBox(height: 12),
                  _buildCoScholasticSection(profile.coScholasticProfile),
                  const SizedBox(height: 24),

                  // 4. ATTENDANCE & ACHIEVEMENTS
                  _buildSectionHeader(
                    icon: LucideIcons.calendarCheck,
                    title: 'Attendance & Achievements',
                    subtitle:
                        '${_formatNum(profile.attendanceProfile.attendancePercentage)}% Attendance • ${profile.achievementProfile.totalAchievements} Achievements',
                    accentColor: const Color(0xFFD97706),
                  ),
                  const SizedBox(height: 12),
                  _buildAttendanceAndAchievementsSection(
                    profile.attendanceProfile,
                    profile.achievementProfile,
                  ),
                  const SizedBox(height: 24),

                  // 5. CAREER GUIDANCE & DATA QUALITY
                  _buildCareerActionCard(context, profile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentHeroHeader(AiStudentSkillsModel profile) {
    final summary = profile.overallSummary;
    final dob = _formatDate(profile.student.dateOfBirth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF355872), Color(0xFF4A7391)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A5F).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: const Icon(
                  LucideIcons.sparkles,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.student.studentName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (profile.student.gender.isNotEmpty)
                          _buildHeroTag(
                            profile.student.gender.toUpperCase(),
                            LucideIcons.user,
                          ),
                        if (dob.isNotEmpty)
                          _buildHeroTag(dob, LucideIcons.calendar),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'v${profile.profileVersion}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildHeroMetricItem(
                    label: 'Academic',
                    value: '${_formatNum(summary.overallAcademicPercentage)}%',
                    sub:
                        'Weighted ${_formatNum(summary.weightedAcademicAverage)}%',
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildHeroMetricItem(
                    label: 'Co-Scholastic',
                    value: '${_formatNum(summary.coScholasticAverage)}%',
                    sub: '${summary.totalCoScholasticAssessments} records',
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildHeroMetricItem(
                    label: 'Homework',
                    value: '${_formatNum(summary.homeworkAveragePoints)}/5',
                    sub: '${summary.totalHomeworkAssignments} tasks',
                  ),
                ),
                _buildVerticalDivider(),
                Expanded(
                  child: _buildHeroMetricItem(
                    label: 'Attendance',
                    value: '${_formatNum(summary.attendancePercentage)}%',
                    sub: '${summary.totalAttendanceSessions} sessions',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroTag(String text, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }

  Widget _buildHeroMetricItem({
    required String label,
    required String value,
    required String sub,
  }) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          sub,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 9.5,
          ),
        ),
      ],
    );
  }

  Widget _buildExploreSkillsBanner(
    BuildContext context,
    AiStudentSkillsModel profile,
  ) {
    final skillCount = profile.skillSummary.totalSkills;
    final topSkill =
        profile.skillSummary.topSkills.isNotEmpty
            ? profile.skillSummary.topSkills.first.skill
            : 'Cognitive & Co-Scholastic Skills';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.pushNamed(RouteConstants.subjectInsights),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6366F1).withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.sparkles,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Explore AI Skill Profile',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$skillCount Skills',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overall Skill Score: ${_formatNum(profile.overallSummary.overallSkillScore)}% • Top: $topSkill',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    LucideIcons.arrowRight,
                    size: 14,
                    color: Color(0xFF4F46E5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accentColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicProfileSection(AiAcademicProfile academic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exam Type Averages Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                  const Expanded(
                    child: Text(
                      'Exam Category Averages',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Overall: ${_formatNum(academic.overallPercentage)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildExamTypeTile(
                      title: 'Main Exams',
                      average: academic.examTypeAverages.mainPublicExam,
                      count: academic.mainExamCount,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildExamTypeTile(
                      title: 'Other Linked',
                      average: academic.examTypeAverages.otherExamLinked,
                      count: academic.otherExamCount,
                      color: const Color(0xFF0891B2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildExamTypeTile(
                      title: 'Internal',
                      average: academic.examTypeAverages.normalInternal,
                      count: academic.normalInternalCount,
                      color: const Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Subject Performance Cards
        if (academic.subjects.isEmpty)
          _buildEmptyCard('No academic subject records available yet.')
        else
          ...academic.subjects.map(_buildAcademicSubjectCard),
      ],
    );
  }

  Widget _buildExamTypeTile({
    required String title,
    required double? average,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              average != null ? '${_formatNum(average)}%' : 'N/A',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          Text(
            '$count exams',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSubjectCard(AiAcademicSubject subject) {
    final trendColor = _getTrendColor(subject.trend);
    final trendIcon = _getTrendIcon(subject.trend);
    final progress = (subject.percentage / 100).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.subject,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatNum(subject.obtainedMarks)} / ${_formatNum(subject.maximumMarks)} Marks • ${subject.assessmentCount} Assessments',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(trendIcon, size: 13, color: trendColor),
                    const SizedBox(width: 4),
                    Text(
                      subject.trend.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${_formatNum(subject.percentage)}%',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(
                subject.percentage >= 85
                    ? const Color(0xFF16A34A)
                    : subject.percentage >= 65
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFD97706),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (subject.mainExamAverage != null)
                _buildMiniStatPill(
                  'Main Exam: ${_formatNum(subject.mainExamAverage!)}%',
                  const Color(0xFFEFF6FF),
                  const Color(0xFF1D4ED8),
                ),
              if (subject.otherExamAverage != null)
                _buildMiniStatPill(
                  'Other Exam: ${_formatNum(subject.otherExamAverage!)}%',
                  const Color(0xFFECFEFF),
                  const Color(0xFF0E7490),
                ),
              if (subject.normalInternalAverage != null)
                _buildMiniStatPill(
                  'Internal: ${_formatNum(subject.normalInternalAverage!)}%',
                  const Color(0xFFF5F3FF),
                  const Color(0xFF6D28D9),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatPill(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildHomeworkProfileSection(AiHomeworkProfile homework) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${homework.totalAssignments}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Assignments',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      Text(
                        '${homework.withTeacherFeedback} with feedback',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF059669).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF059669).withValues(alpha: 0.16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_formatNum(homework.averagePoints)} / 5',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Avg Points',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      Text(
                        '${_formatNum(homework.totalPoints)} total pts',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (homework.subjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Subject Homework Performance',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            ...homework.subjects.map(
              (sub) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sub.subject,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            '${sub.totalAssignments} assignments • ${_formatNum(sub.totalPoints)} pts',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Avg ${_formatNum(sub.averagePoints)}/5',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6D28D9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (homework.derivedSkills.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Derived Skills from Homework',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  homework.derivedSkills
                      .map(
                        (s) => _buildMiniStatPill(
                          s,
                          const Color(0xFFF3F4F6),
                          const Color(0xFF374151),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoScholasticSection(AiCoScholasticProfile coScholastic) {
    if (coScholastic.areas.isEmpty) {
      return _buildEmptyCard('No co-scholastic assessments recorded yet.');
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children:
            coScholastic.areas.map((area) {
              final progress = (area.averageScore / 100).clamp(0.0, 1.0);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            area.area,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_formatNum(area.averageScore)}% (${area.assessmentCount})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0D9488),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFE5E7EB),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF0D9488),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAttendanceAndAchievementsSection(
    AiAttendanceProfile attendance,
    AiAchievementProfile achievements,
  ) {
    return Column(
      children: [
        // Attendance Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                  const Expanded(
                    child: Text(
                      'Attendance Summary',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Text(
                    '${_formatNum(attendance.attendancePercentage)}%',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildCountBox(
                      'Present',
                      attendance.present,
                      const Color(0xFF16A34A),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCountBox(
                      'Absent',
                      attendance.absent,
                      const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCountBox(
                      'Late',
                      attendance.lateCount,
                      const Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildCountBox(
                      'Leave',
                      attendance.leave,
                      const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Achievements Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
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
                  const Expanded(
                    child: Text(
                      'Recognitions & Achievements',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${achievements.totalAchievements} Total',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (achievements.totalAchievements == 0)
                const Text(
                  'No achievements logged yet.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...achievements.byCategory.map(
                      (c) => _buildMiniStatPill(
                        '${c.label.toUpperCase()}: ${c.count}',
                        const Color(0xFFFEF3C7),
                        const Color(0xFFB45309),
                      ),
                    ),
                    ...achievements.byLevel.map(
                      (l) => _buildMiniStatPill(
                        '${l.label.toUpperCase()}: ${l.count}',
                        const Color(0xFFE0E7FF),
                        const Color(0xFF3730A3),
                      ),
                    ),
                    ...achievements.byPosition.map(
                      (p) => _buildMiniStatPill(
                        '${p.label.toUpperCase()}: ${p.count}',
                        const Color(0xFFDCFCE7),
                        const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountBox(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCareerActionCard(
    BuildContext context,
    AiStudentSkillsModel profile,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap:
          () => context.pushNamed(
            RouteConstants.careerGuidance,
            extra: widget.studentId,
          ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF355872), Color(0xFF1E3A5F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A5F).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                LucideIcons.compass,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Career Prediction & Roadmap',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.careerAiInput.ready
                        ? 'View recommended stream, career roadmap & top 10 job matches'
                        : 'Predict ideal career domains, academic stream & top job matches',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              LucideIcons.chevronRight,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
      ),
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return const Color(0xFF16A34A);
      case 'declining':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend.toLowerCase()) {
      case 'improving':
        return LucideIcons.trendingUp;
      case 'declining':
        return LucideIcons.trendingDown;
      default:
        return LucideIcons.minus;
    }
  }
}
