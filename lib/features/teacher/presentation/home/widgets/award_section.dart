import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/detail_screen_args.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AwardSection extends StatelessWidget {
  const AwardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Awards and Accomplishments",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                context.pushNamed(
                  RouteConstants.schoolAchievements,
                  extra: true,
                );
              },
              child: Text("View", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        SizedBox(height: 10),

        Consumer<AchievementProvider>(
          builder: (context, provider, _) {
            final achievements = provider.schoolAchievements;

            if (provider.isLoading) {
              return Center(child: CommonShimmerTile());
            } else if (achievements.isEmpty) {
              return emptyScreen(
                message: "No Achievements Avaliable",
                heightMultiplier: 5,
              );
            }
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                return ItemCard(
                  title: achievement.title ?? "",
                  description: achievement.description ?? "",
                  onTap: () {
                    context.pushNamed(
                      RouteConstants.achievementDetailsScreen,
                      extra: DetailScreenArgs(
                        id: achievement.id ?? 0,
                        forStaff: true,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
