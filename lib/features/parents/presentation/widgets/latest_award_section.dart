import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
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
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: Color(0xFF00AEF0), size: 24),
              SizedBox(width: 8),
              Text(
                "Awards",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  context.pushNamed(
                    RouteConstants.schoolAchievements,
                    extra: false,
                  );
                },
                child: Text('View'),
              ),
            ],
          ),

          Consumer<AchievementProvider>(
            builder: (context, provider, _) {
              final achievements = provider.schoolAchievementsLatest;
              if (provider.isLatestLoading) {
                return commonShimmerList(itemCount: 3);
              } else if (achievements.isEmpty) {
                return emptyScreen(
                  message: "No Awards Available",
                  heightMultiplier: 5,
                );
              }

              return ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
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
                        RouteConstants.achievementDetailsScreen,
                        extra: DetailScreenArgs(
                          id: achievement.id ?? 0,
                          forStaff: false,
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
