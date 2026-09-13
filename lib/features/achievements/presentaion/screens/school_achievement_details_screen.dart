import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SchoolAchievementDetailsScreen extends StatefulWidget {
  final int achievementId;
  final bool forStaff;
  const SchoolAchievementDetailsScreen({
    super.key,
    required this.achievementId,
    required this.forStaff,
  });

  @override
  State<SchoolAchievementDetailsScreen> createState() =>
      _SchoolAchievementDetailsScreenState();
}

class _SchoolAchievementDetailsScreenState
    extends State<SchoolAchievementDetailsScreen> {
  late AchievementProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<AchievementProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchSingleAchievement(
        achievementId: widget.achievementId,
        forStaff: widget.forStaff,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CommonAppBar(
        title: "Achievement Details",
        isBackButton: true,
        // No actions — view-only screen
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, _) {
          final achievement = provider.singleAchievement;

          if (provider.isLoading && achievement == null) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.grey,
              ),
            );
          }

          if (achievement == null) {
            return const Center(child: Text("No achievement details found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _achievementHeader(achievement),
                const SizedBox(height: 14),
                _detailsCard(achievement),
                const SizedBox(height: 14),
                _studentsCard(achievement.studentAchievements ?? []),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Widgets (view-only) ──────────────────────────────────────────────────────

Widget _achievementHeader(dynamic achievement) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.emoji_events,
            color: Colors.amber.shade700,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                capitalizeEachWord(achievement.title ?? ""),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                achievement.description ?? "No description",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _detailsCard(dynamic achievement) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      children: [
        _detailRow(
          Icons.category_outlined,
          "Category",
          capitalizeEachWord(achievement.category ?? "-"),
        ),
        _detailRow(
          Icons.military_tech_outlined,
          "Level",
          capitalizeEachWord(achievement.level ?? "-"),
        ),
        _detailRow(
          Icons.calendar_today_outlined,
          "Date",
          DateFormatter.formatDateTime(achievement.date ?? DateTime.now()),
        ),
        _detailRow(
          Icons.person_outline,
          "Recorded by",
          achievement.user?.name ?? "-",
          showDivider: false,
        ),
      ],
    ),
  );
}

Widget _detailRow(
  IconData icon,
  String label,
  String value, {
  bool showDivider = true,
}) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const Spacer(),
            Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      if (showDivider) Divider(height: 1, color: Colors.grey.shade200),
    ],
  );
}

Widget _studentsCard(List<dynamic> students) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.workspace_premium_outlined, size: 21),
            const SizedBox(width: 8),
            const Text(
              "Students",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              "${students.length}",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (students.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: Text("No students added")),
          )
        else
          ...students.map((item) {
            final student = item.student;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    child: Text(
                      (student?.fullName?.isNotEmpty ?? false)
                          ? student!.fullName![0].toUpperCase()
                          : "?",
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student?.fullName ?? "Unknown Student",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [student?.classGrade?.classname, student?.regNo]
                              .where(
                                (value) =>
                                    value != null &&
                                    value.toString().isNotEmpty,
                              )
                              .join(" • "),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if ((item.status ?? "").isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.status!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
      ],
    ),
  );
}
