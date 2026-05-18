import 'package:flutter/material.dart';

class CareerInsightsScreen extends StatelessWidget {
  const CareerInsightsScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Career Guidance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        leading: const BackButton(color: Color(0xFF111827)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // ── Suggested Career Areas ──────────────────────────────────────
          SuggestedCareerAreasWidget(
            careers: const [
              CareerItem(
                label: 'HIGH GROWTH',
                title: 'Environmental\nScience',
                icon: Icons.eco_rounded,
                iconColor: Color(0xFF16A34A),
                iconBg: Color(0xFFDCFCE7),
                borderColor: Color(0xFF16A34A),
              ),
              CareerItem(
                label: 'STABLE PATH',
                title: 'Data\nAnalyst',
                icon: Icons.bar_chart_rounded,
                iconColor: Color(0xFFF59E0B),
                iconBg: Color(0xFFFEF3C7),
                borderColor: Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 16),
 
          // ── Student Strengths ───────────────────────────────────────────
          StudentStrengthsWidget(
            strengths: const ['Logical Reasoning', 'Curiosity'],
          ),
          const SizedBox(height: 12),
 
          // ── Areas to Improve ────────────────────────────────────────────
          AreasToImproveWidget(
            areas: const ['Public Speaking'],
          ),
          const SizedBox(height: 20),
 
          // ── Career Roadmap ──────────────────────────────────────────────
          CareerRoadmapWidget(
            milestones: const [
              RoadmapMilestone(
                stage: 'After 10th Grade',
                description:
                    'Focus on Science stream. Select Physics, Chemistry, and Math to build a technical foundation.',
                dotColor: Color(0xFF22C55E),
              ),
              RoadmapMilestone(
                stage: 'After 12th Grade',
                description:
                    'Undergraduate Research. Pursue degrees in Environmental Engineering or Data Science.',
                dotColor: Color(0xFFF59E0B),
              ),
              RoadmapMilestone(
                stage: 'Future Direction',
                description:
                    'Sustainable technology. Leading innovative projects that combine data and ecology.',
                dotColor: Color(0xFFEF4444),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// 1. SUGGESTED CAREER AREAS WIDGET
// ─────────────────────────────────────────────────────────────────────────────
 
class CareerItem {
  final String label;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color borderColor;
 
  const CareerItem({
    required this.label,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
  });
}
 
class SuggestedCareerAreasWidget extends StatelessWidget {
  final List<CareerItem> careers;
  final String heading;
 
  const SuggestedCareerAreasWidget({
    super.key,
    required this.careers,
    this.heading = 'Suggested Career Areas',
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.radio_button_checked_rounded,
          iconColor: const Color(0xFF16A34A),
          text: heading,
        ),
        const SizedBox(height: 10),
        Row(
          children: List.generate(careers.length, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < careers.length - 1 ? 10 : 0),
                child: _CareerCard(item: careers[i]),
              ),
            );
          }),
        ),
      ],
    );
  }
}
 
class _CareerCard extends StatelessWidget {
  final CareerItem item;
  const _CareerCard({required this.item});
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: item.borderColor, width: 3.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280).withAlpha(200),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// 2. STUDENT STRENGTHS WIDGET
// ─────────────────────────────────────────────────────────────────────────────
 
class StudentStrengthsWidget extends StatelessWidget {
  final List<String> strengths;
  final String heading;
 
  const StudentStrengthsWidget({
    super.key,
    required this.strengths,
    this.heading = 'Student Strengths',
  });
 
  @override
  Widget build(BuildContext context) {
    return _TagSectionCard(
      icon: Icons.check_circle_outline_rounded,
      iconColor: const Color(0xFF16A34A),
      heading: heading,
      tags: strengths,
      tagTextColor: const Color(0xFF166534),
      tagBgColor: const Color(0xFFDCFCE7),
      tagBorderColor: const Color(0xFFBBF7D0),
      cardBg: const Color(0xFFF0FDF4),
      cardBorderColor: const Color(0xFFBBF7D0),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// 3. AREAS TO IMPROVE WIDGET
// ─────────────────────────────────────────────────────────────────────────────
 
class AreasToImproveWidget extends StatelessWidget {
  final List<String> areas;
  final String heading;
 
  const AreasToImproveWidget({
    super.key,
    required this.areas,
    this.heading = 'Areas to Improve',
  });
 
  @override
  Widget build(BuildContext context) {
    return _TagSectionCard(
      icon: Icons.trending_up_rounded,
      iconColor: const Color(0xFFEF4444),
      heading: heading,
      tags: areas,
      tagTextColor: const Color(0xFF991B1B),
      tagBgColor: const Color(0xFFFFE4E4),
      tagBorderColor: const Color(0xFFFECACA),
      cardBg: const Color(0xFFFFF5F5),
      cardBorderColor: const Color(0xFFFECACA),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// SHARED: Tag Section Card (used by Strengths & Areas to Improve)
// ─────────────────────────────────────────────────────────────────────────────
 
class _TagSectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String heading;
  final List<String> tags;
  final Color tagTextColor;
  final Color tagBgColor;
  final Color tagBorderColor;
  final Color cardBg;
  final Color cardBorderColor;
 
  const _TagSectionCard({
    required this.icon,
    required this.iconColor,
    required this.heading,
    required this.tags,
    required this.tagTextColor,
    required this.tagBgColor,
    required this.tagBorderColor,
    required this.cardBg,
    required this.cardBorderColor,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(icon: icon, iconColor: iconColor, text: heading),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((t) => _Tag(
                      label: t,
                      textColor: tagTextColor,
                      bgColor: tagBgColor,
                      borderColor: tagBorderColor,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
 
class _Tag extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
 
  const _Tag({
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
 
// ─────────────────────────────────────────────────────────────────────────────
// 4. CAREER ROADMAP WIDGET
// ─────────────────────────────────────────────────────────────────────────────
 
class RoadmapMilestone {
  final String stage;
  final String description;
  final Color dotColor;
 
  const RoadmapMilestone({
    required this.stage,
    required this.description,
    required this.dotColor,
  });
}
 
class CareerRoadmapWidget extends StatelessWidget {
  final List<RoadmapMilestone> milestones;
  final String heading;
 
  const CareerRoadmapWidget({
    super.key,
    required this.milestones,
    this.heading = 'Career Roadmap',
  });
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          icon: Icons.route_rounded,
          iconColor: const Color(0xFF16A34A),
          text: heading,
          fontSize: 16,
        ),
        const SizedBox(height: 14),
        ...List.generate(milestones.length, (i) {
          final milestone = milestones[i];
          final isLast = i == milestones.length - 1;
          return _RoadmapStep(
            milestone: milestone,
            isLast: isLast,
          );
        }),
      ],
    );
  }
}
 
class _RoadmapStep extends StatelessWidget {
  final RoadmapMilestone milestone;
  final bool isLast;
 
  const _RoadmapStep({required this.milestone, required this.isLast});
 
  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 28,
            child: Column(
              children: [
                // Dot
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: milestone.dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: milestone.dotColor.withAlpha(80),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                // Line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
 
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: milestone.dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          milestone.stage,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: milestone.dotColor,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      milestone.description,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF374151).withAlpha(220),
                        height: 1.6,
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
}
 
// ─────────────────────────────────────────────────────────────────────────────
// SHARED: Section Heading
// ─────────────────────────────────────────────────────────────────────────────
 
class _SectionHeading extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final double fontSize;
 
  const _SectionHeading({
    required this.icon,
    required this.iconColor,
    required this.text,
    this.fontSize = 14.5,
  });
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 18),
        const SizedBox(width: 7),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}