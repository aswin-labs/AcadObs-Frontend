import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/students/acheivement/achievement_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AchievementDetailsScreen extends StatelessWidget {
  final AchievementModel achievementModel;
  const AchievementDetailsScreen({super.key, required this.achievementModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: achievementModel.title.toString(),
        isBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 226,
              decoration: BoxDecoration(
                color: const Color(0xFFCEFFD3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  LucideIcons.filePlus2,
                  color: Color(0xFF5DD168),
                  size: 150,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              capitalizeEachWord(achievementModel.title ?? ""),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              capitalizeEachWord(achievementModel.description ?? ""),
              style: const TextStyle(color: Color(0xFF949494)),
            ),

            const SizedBox(height: 20),

            // Students list
            Expanded(
              child: ListView.builder(
                itemCount: achievementModel.studentAchievements?.length ?? 0,
                itemBuilder: (context, index) {
                  final studentAchievement =
                      achievementModel.studentAchievements?[index];
                  return ProfileTile(
                    name: studentAchievement?.student?.fullName ?? "",
                    description: studentAchievement?.student?.regNo ?? "",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
