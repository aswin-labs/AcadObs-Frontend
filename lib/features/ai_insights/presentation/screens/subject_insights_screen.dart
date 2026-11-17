import 'package:acadobs/features/ai_insights/data/models/ai_student_skills_model.dart';
import 'package:acadobs/features/ai_insights/presentation/provider/ai_insights_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class SubjectInsightsScreen extends StatefulWidget {
  const SubjectInsightsScreen({super.key});

  @override
  State<SubjectInsightsScreen> createState() => _SubjectInsightsScreenState();
}

class _SubjectInsightsScreenState extends State<SubjectInsightsScreen> {
  String _selectedStatusFilter = 'All';

  static const List<Map<String, String>> _statusFilters = [
    {'label': 'All Skills', 'value': 'All'},
    {'label': 'Strengths', 'value': 'strength'},
    {'label': 'Developing', 'value': 'developing'},
    {'label': 'Needs Focus', 'value': 'needs_improvement'},
  ];

  String _formatNum(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  String _formatSourceLabel(String raw) {
    return raw
        .split('_')
        .map(
          (w) =>
              w.isEmpty
                  ? ''
                  : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: CommonAppBar(title: 'AI Skill Profile', isBackButton: true),
      body: Consumer<AiInsightsProvider>(
        builder: (context, provider, _) {
          final profile = provider.aiProfile;
          if (profile == null) {
            return const Center(
              child: Text(
                'No skill profile loaded.',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
            );
          }

          final skillSummary = profile.skillSummary;
          final allSkills = skillSummary.allSkills;
          final filteredSkills =
              _selectedStatusFilter == 'All'
                  ? allSkills
                  : allSkills
                      .where(
                        (s) =>
                            s.status.toLowerCase() ==
                            _selectedStatusFilter.toLowerCase(),
                      )
                      .toList();

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overall Skill Score Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.student.studentName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Overall Skill Index',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${skillSummary.totalSkills} skills identified across Cognitive, Co-Scholastic & Demonstrated areas',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.28),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '${_formatNum(profile.overallSummary.overallSkillScore)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Skill Score',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Top Skills Spotlight
                if (skillSummary.topSkills.isNotEmpty) ...[
                  const Row(
                    children: [
                      Icon(
                        LucideIcons.award,
                        size: 18,
                        color: Color(0xFF4F46E5),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Top Strengths Spotlight',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 126,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: skillSummary.topSkills.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = skillSummary.topSkills[index];
                        return _buildTopSkillCard(item, index + 1);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Filter Chips for All Skills
                const Text(
                  'All Identified Skills',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _statusFilters.map((filter) {
                          final isSelected =
                              _selectedStatusFilter == filter['value'];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filter['label']!),
                              selected: isSelected,
                              onSelected: (_) {
                                setState(() {
                                  _selectedStatusFilter = filter['value']!;
                                });
                              },
                              selectedColor: const Color(0xFF4F46E5),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFF374151),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? const Color(0xFF4F46E5)
                                          : const Color(0xFFE5E7EB),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
                const SizedBox(height: 14),

                if (filteredSkills.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(
                      child: Text(
                        'No skills match this filter.',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  )
                else
                  ...filteredSkills.map(_buildSkillDetailCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopSkillCard(AiSkillItem item, int rank) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#$rank • ${item.category}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ),
              if (item.score != null) ...[
                const SizedBox(width: 6),
                Text(
                  '${_formatNum(item.score!)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ],
          ),
          Text(
            item.skill,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          Row(
            children: [
              const Icon(
                LucideIcons.trendingUp,
                size: 13,
                color: Color(0xFF16A34A),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${item.level.toUpperCase()} • ${item.scoreObservations} obs',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillDetailCard(AiSkillItem skill) {
    final statusColor = _getStatusColor(skill.status);
    final scoreVal = skill.score;
    final progress =
        scoreVal != null ? (scoreVal / 100).clamp(0.0, 1.0) : null;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.skill,
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
                      children: [
                        _buildBadge(
                          skill.category,
                          const Color(0xFFF3F4F6),
                          const Color(0xFF374151),
                        ),
                        _buildBadge(
                          skill.status.replaceAll('_', ' ').toUpperCase(),
                          statusColor.withValues(alpha: 0.12),
                          statusColor,
                        ),
                        _buildBadge(
                          'Confidence: ${skill.confidence}',
                          const Color(0xFFEEF2FF),
                          const Color(0xFF4F46E5),
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
                  Text(
                    scoreVal != null ? '${_formatNum(scoreVal)}%' : 'Observed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  Text(
                    skill.level.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                backgroundColor: const Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children:
                      skill.dataSources
                          .map(
                            (src) => Text(
                              '• ${_formatSourceLabel(src)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              Text(
                '${skill.scoreObservations} obs • ${skill.trend}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'strength':
        return const Color(0xFF16A34A);
      case 'developing':
        return const Color(0xFF2563EB);
      case 'needs_improvement':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF4F46E5);
    }
  }
}
