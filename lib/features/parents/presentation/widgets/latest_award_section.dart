import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/features/notices/presentation/widgets/notice_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/detail_screen_args.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LatestAwardSection extends StatelessWidget {
  const LatestAwardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AchievementProvider>(
      builder: (context, provider, _) {
        final achievements = provider.schoolAchievementsLatest;
        final isLoading = provider.isLatestLoading && achievements.isEmpty;

        if (!provider.isLatestLoading && achievements.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Color(0xFF00AEF0), size: 24),
                  const SizedBox(width: 8),
                  const Text(
                    "Awards",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(
                        RouteConstants.schoolAchievements,
                        extra: false,
                      );
                    },
                    child: const Text('View'),
                  ),
                ],
              ),
              if (isLoading)
                commonShimmerList(itemCount: 3)
              else
                ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    final achievement = achievements[index];
                    return NoticeCard(
                      title: achievement.title ?? "",
                      date: DateFormatter.formatDateTime(
                        achievement.date ?? DateTime.now(),
                      ),
                      icon: Icons.workspace_premium,
                      time: TimeFormatter.formatTime(
                        achievement.createdAt ?? DateTime.now(),
                      ),
                      onTap: () {
                        context.pushNamed(
                          RouteConstants.schoolAchievementDetailsScreen,
                          extra: DetailScreenArgs(
                            id: achievement.id ?? 0,
                            forStaff: false,
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
