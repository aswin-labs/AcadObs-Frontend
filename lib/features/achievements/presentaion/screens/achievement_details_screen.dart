import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/achievements/presentaion/provider/acheivement_provider.dart';
import 'package:acadobs/features/students/acheivement/achievement_model.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AchievementDetailsScreen extends StatelessWidget {
  final AchievementModel achievementModel;
  const AchievementDetailsScreen({super.key, required this.achievementModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: capitalizeEachWord(achievementModel.title.toString()),
        isBackButton: true,
        actions: [
          Consumer<AchievementProvider>(
            builder: (context, provider, _) {
              return CustomPopupMenu(
                // showEdit: false,
                onEdit: () {
                  context.pushNamed(
                    RouteConstants.editAchievement,
                    extra: achievementModel,
                  );
                },
                onDelete: () {
                  showConfirmationDialog(
                    context: context,
                    title: 'Delete achievement',
                    content: 'Do you want to delete the achievement?',
                    onConfirm: () async {
                      Navigator.of(
                        context,
                      ).pop(); // close the confirmation dialog first

                      final ok = await context
                          .read<AchievementProvider>()
                          .deleteAchievement(achievementModel.id ?? 0);

                      if (ok) {
                        if (!context.mounted) return;
                        CustomSnackbar.show(
                          context,
                          message: "achievement deleted",
                          type: SnackbarType.success,
                        );
                        Navigator.pop(context); // close the NoteDetailsScreen
                      } else {
                        if (!context.mounted) return;
                        CustomErrorDialog.show(
                          context,
                          "Failed to delete achievement",
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
            Text(
              "Prizes: ",
              style: context.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            // Students list
            Expanded(
              child: ListView.builder(
                itemCount: achievementModel.studentAchievements?.length ?? 0,
                itemBuilder: (context, index) {
                  final studentAchievement =
                      achievementModel.studentAchievements?[index];
                  return ProfileTile(
                    name:
                        "${studentAchievement?.student?.fullName ?? ""} - ${studentAchievement?.status ?? ""}",
                    description:
                        studentAchievement?.student?.studentClass?.classname ??
                        "",
                    suffixText: "",
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
