import 'package:acadobs/features/ai_insights/data/models/ai_career_prediction_model.dart';
import 'package:acadobs/features/ai_insights/presentation/provider/ai_insights_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class CareerInsightsScreen extends StatefulWidget {
  final int? studentId;

  const CareerInsightsScreen({super.key, this.studentId});

  @override
  State<CareerInsightsScreen> createState() => _CareerInsightsScreenState();
}

class _CareerInsightsScreenState extends State<CareerInsightsScreen> {
  /// 0 = Overview & Roadmap, 1 = Top Career Matches
  int _selectedTabIndex = 0;

  /// Rank of currently expanded job card (defaults to #1 so it's neat & scannable)
  int? _expandedJobRank = 1;

  int _resolveStudentId(AiInsightsProvider provider) {
    if (widget.studentId != null && widget.studentId! > 0) {
      return widget.studentId!;
    }
    if (provider.activeStudentId != null && provider.activeStudentId! > 0) {
      return provider.activeStudentId!;
    }
    return provider.aiProfile?.student.studentId ?? 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<AiInsightsProvider>();
      final id = _resolveStudentId(provider);
      if (id > 0) {
        provider.fetchStudentCareerPrediction(studentId: id);
      }
    });
  }

  String _formatNum(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: CommonAppBar(title: 'AI Career Prediction', isBackButton: true),
      body: Consumer<AiInsightsProvider>(
        builder: (context, provider, _) {
          final studentId = _resolveStudentId(provider);

          if (provider.isCareerLoading && provider.careerPrediction == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const CircularProgressIndicator(
                        color: Color(0xFF355872),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Generating AI Career Prediction...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Analyzing academic marks, cognitive skills, and co-scholastic strengths to map ideal career paths.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.careerErrorMessage != null &&
              provider.careerPrediction == null) {
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
                        'Unable to Load Career Prediction',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.careerErrorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed:
                            studentId > 0
                                ? () {
                                  provider.fetchStudentCareerPrediction(
                                    studentId: studentId,
                                    forceRefresh: true,
                                  );
                                }
                                : null,
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
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final prediction = provider.careerPrediction;
          if (prediction == null) {
            return const Center(
              child: Text(
                'No career prediction data available.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          final studentName = provider.aiProfile?.student.studentName;

          return RefreshIndicator(
            color: const Color(0xFF355872),
            onRefresh:
                () => provider.fetchStudentCareerPrediction(
                  studentId: studentId,
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
                  // 1. Primary Career Domain & Stream Hero Card
                  _buildCareerHeroCard(prediction, studentName),
                  const SizedBox(height: 16),

                  // 2. Clean 2-Tab Switcher
                  _buildSegmentedTabBar(prediction.top10Jobs.length),
                  const SizedBox(height: 18),

                  // 3. Active Tab Content
                  if (_selectedTabIndex == 0)
                    _buildOverviewAndRoadmapTab(prediction.careerPath, () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    })
                  else
                    _buildTopJobsTab(prediction.top10Jobs),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCareerHeroCard(
    AiCareerPredictionModel prediction,
    String? studentName,
  ) {
    final path = prediction.careerPath;

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
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  LucideIcons.compass,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName != null && studentName.isNotEmpty
                          ? '$studentName • AI CAREER PATH'
                          : 'PRIMARY CAREER DOMAIN',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      path.primaryCareerDomain.isNotEmpty
                          ? path.primaryCareerDomain
                          : 'Recommended Career Path',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (path.recommendedAcademicStream.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      LucideIcons.graduationCap,
                      color: Color(0xFFFDE68A),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recommended Academic Stream',
                          style: TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          path.recommendedAcademicStream,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (path.secondaryCareerDomains.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Secondary Career Domains:',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children:
                  path.secondaryCareerDomains
                      .map(
                        (domain) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            domain,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentedTabBar(int jobsCount) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              index: 0,
              icon: LucideIcons.sparkles,
              label: 'Overview & Roadmap',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _buildTabButton(
              index: 1,
              icon: LucideIcons.briefcase,
              label: 'Top $jobsCount Careers',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF355872) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF4B5563),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── TAB 0: OVERVIEW & ROADMAP ──────────────────────────────────────
  Widget _buildOverviewAndRoadmapTab(
    AiCareerPathDetails path,
    VoidCallback onViewTopCareers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Executive Career Summary
        if (path.overallCareerSummary.isNotEmpty) ...[
          _buildSectionCard(
            title: 'AI Career Assessment Summary',
            icon: LucideIcons.fileText,
            accentColor: const Color(0xFF2563EB),
            child: Text(
              path.overallCareerSummary,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF374151),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Core Strengths
        if (path.coreStrengths.isNotEmpty) ...[
          _buildSectionCard(
            title: 'Core Strengths',
            icon: LucideIcons.trendingUp,
            accentColor: const Color(0xFF16A34A),
            child: Column(
              children:
                  path.coreStrengths
                      .map(
                        (item) => _buildBulletItem(
                          text: item,
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF16A34A),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Areas for Growth
        if (path.areasForGrowth.isNotEmpty) ...[
          _buildSectionCard(
            title: 'Areas for Growth',
            icon: LucideIcons.target,
            accentColor: const Color(0xFFD97706),
            child: Column(
              children:
                  path.areasForGrowth
                      .map(
                        (item) => _buildBulletItem(
                          text: item,
                          icon: LucideIcons.arrowUpRight,
                          color: const Color(0xFFD97706),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Actionable Career Roadmap
        _buildRoadmapCard(path.careerRoadmap),
        const SizedBox(height: 18),

        // CTA to switch to Top 10 Careers tab
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onViewTopCareers,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF355872), Color(0xFF1E3A5F)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A5F).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.briefcase, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Explore Top 10 Recommended Careers',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(LucideIcons.arrowRight, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoadmapCard(AiCareerRoadmap roadmap) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.map,
                  color: Color(0xFF7C3AED),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Step-by-Step Career Roadmap',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (roadmap.schoolFocus.isNotEmpty) ...[
            _buildRoadmapSubSection(
              stepTitle: '1. School Focus',
              items: roadmap.schoolFocus,
              color: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 14),
          ],
          if (roadmap.higherEducationOptions.isNotEmpty) ...[
            _buildRoadmapSubSection(
              stepTitle: '2. Higher Education Options',
              items: roadmap.higherEducationOptions,
              color: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 14),
          ],
          if (roadmap.skillBuildingActions.isNotEmpty)
            _buildRoadmapSubSection(
              stepTitle: '3. Skill Building Actions',
              items: roadmap.skillBuildingActions,
              color: const Color(0xFF0D9488),
            ),
        ],
      ),
    );
  }

  Widget _buildRoadmapSubSection({
    required String stepTitle,
    required List<String> items,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stepTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF374151),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 1: TOP 10 CAREER MATCHES ──────────────────────────────────
  Widget _buildTopJobsTab(List<AiPredictedJob> jobs) {
    if (jobs.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Center(
          child: Text(
            'No career matches available.',
            style: TextStyle(color: Color(0xFF6B7280)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Tap any career card to view required skills, education pathway & career progression.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ),
        ...jobs.map(_buildJobCard),
      ],
    );
  }

  Widget _buildJobCard(AiPredictedJob job) {
    final isExpanded = _expandedJobRank == job.rank;
    final fitColor = _getFitColor(job.fitLevel);
    final growthSteps = job.growthSteps;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              isExpanded
                  ? const Color(0xFF355872).withValues(alpha: 0.4)
                  : const Color(0xFFE5E7EB),
          width: isExpanded ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          setState(() {
            _expandedJobRank = isExpanded ? null : job.rank;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Rank + Job Title + Match %
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color:
                          job.rank <= 3
                              ? const Color(0xFF1E3A5F)
                              : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '#${job.rank}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color:
                              job.rank <= 3
                                  ? Colors.white
                                  : const Color(0xFF374151),
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
                          job.jobTitle,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              job.careerDomain,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (job.fitLevel.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: fitColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  job.fitLevel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: fitColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFA7F3D0),
                          ),
                        ),
                        child: Text(
                          '${_formatNum(job.matchPercentage)}%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        isExpanded
                            ? LucideIcons.chevronUp
                            : LucideIcons.chevronDown,
                        size: 16,
                        color: const Color(0xFF9CA3AF),
                      ),
                    ],
                  ),
                ],
              ),

              if (!isExpanded && job.whyBestForStudent.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  job.whyBestForStudent,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],

              // Expanded Details
              if (isExpanded) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFE5E7EB)),
                const SizedBox(height: 12),

                // Why it fits
                if (job.whyBestForStudent.isNotEmpty) ...[
                  const Text(
                    'Why This Fits:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.whyBestForStudent,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF374151),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Supporting Subjects
                if (job.supportingSubjects.isNotEmpty) ...[
                  const Text(
                    'Supporting Subjects:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        job.supportingSubjects
                            .map(
                              (s) => _buildPill(
                                s,
                                const Color(0xFFEFF6FF),
                                const Color(0xFF1D4ED8),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Matching Student Skills
                if (job.matchingStudentSkills.isNotEmpty) ...[
                  const Text(
                    'Matching Student Skills:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        job.matchingStudentSkills
                            .map(
                              (s) => _buildPill(
                                s,
                                const Color(0xFFDCFCE7),
                                const Color(0xFF15803D),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Skills to Develop
                if (job.skillsToDevelop.isNotEmpty) ...[
                  const Text(
                    'Skills to Develop:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children:
                        job.skillsToDevelop
                            .map(
                              (s) => _buildPill(
                                s,
                                const Color(0xFFFEF3C7),
                                const Color(0xFFB45309),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Education Pathway
                if (job.educationPathway.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              LucideIcons.graduationCap,
                              size: 15,
                              color: Color(0xFF355872),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Education Pathway',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.educationPathway,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Career Growth Progression
                if (growthSteps.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDDD6FE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              LucideIcons.trendingUp,
                              size: 15,
                              color: Color(0xFF6D28D9),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Career Progression Path',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4C1D95),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            for (int i = 0; i < growthSteps.length; i++) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFFC4B5FD),
                                  ),
                                ),
                                child: Text(
                                  growthSteps[i],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF5B21B6),
                                  ),
                                ),
                              ),
                              if (i < growthSteps.length - 1)
                                const Icon(
                                  LucideIcons.arrowRight,
                                  size: 12,
                                  color: Color(0xFF7C3AED),
                                ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBulletItem({
    required String text,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Color _getFitColor(String fitLevel) {
    final lower = fitLevel.toLowerCase();
    if (lower.contains('best')) return const Color(0xFF16A34A);
    if (lower.contains('good')) return const Color(0xFF2563EB);
    return const Color(0xFFD97706);
  }
}
