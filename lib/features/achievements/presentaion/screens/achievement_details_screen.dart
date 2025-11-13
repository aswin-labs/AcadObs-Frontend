import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';

import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';

class AchievementDetailsScreen extends StatefulWidget {
  final int achievementId;
  final bool forStaff;
  const AchievementDetailsScreen({
    super.key,
    required this.achievementId,
    required this.forStaff,
  });

  @override
  State<AchievementDetailsScreen> createState() =>
      _AchievementDetailsScreenState();
}

class _AchievementDetailsScreenState extends State<AchievementDetailsScreen> {
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
        actions: [
          if (widget.forStaff)
            Consumer<AchievementProvider>(
              builder: (context, provider, _) {
                return CustomPopupMenu(
                  onEdit: () {
                    context.pushNamed(
                      RouteConstants.editAchievement,
                      extra: provider.singleAchievement,
                    );
                  },
                  onDelete: () {
                    showConfirmationDialog(
                      context: context,
                      title: 'Delete Achievement',
                      content:
                          'Are you sure you want to delete this achievement? This action cannot be undone.',
                      onConfirm: () async {
                        Navigator.of(context).pop();

                        final ok = await context
                            .read<AchievementProvider>()
                            .deleteAchievement(
                              provider.singleAchievement?.id ?? 0,
                            );

                        if (ok) {
                          if (!context.mounted) return;
                          CustomSnackbar.show(
                            context,
                            message: "Achievement deleted successfully",
                            type: SnackbarType.success,
                          );
                          Navigator.pop(context);
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
      body: Consumer<AchievementProvider>(
        builder: (context, provider, _) {
          final achievement = provider.singleAchievement;

          if (provider.isLoading && achievement == null) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: commonShimmerList(),
            );
          }

          if (achievement == null) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Details Found',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final studentCount = achievement.studentAchievements?.length ?? 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section with Trophy Icon
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade50, Colors.blue.shade300],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(45),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.emoji_events,
                            size: 80,
                            color: Colors.blue.shade300,
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(9),
                              blurRadius: 10,
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withAlpha(23),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.title,
                                    size: 20,
                                    color: Colors.amber,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Achievement Title",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              capitalizeEachWord(achievement.title ?? ""),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Description Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(9),
                              blurRadius: 10,
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
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withAlpha(23),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.description_outlined,
                                    size: 20,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Description",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              capitalizeEachWord(
                                achievement.description ??
                                    "No description available",
                              ),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[700],
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Winners Section Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(23),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              size: 20,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            "Award Winners",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withAlpha(23),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "$studentCount Winner${studentCount != 1 ? 's' : ''}",
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Winners List
                      if (studentCount == 0)
                        Column(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "No winners yet",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      else
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(9),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(8),
                            itemCount: studentCount,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 5),
                            itemBuilder: (context, index) {
                              final studentAchievement =
                                  achievement.studentAchievements?[index];
                              final studentName =
                                  studentAchievement?.student?.fullName ??
                                  "Unknown";
                              final status = studentAchievement?.status ?? "";
                              final className =
                                  studentAchievement
                                      ?.student
                                      ?.classGrade
                                      ?.classname ??
                                  "";

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    // Position Badge
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: _getPositionColors(index),
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          "${index + 1}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Student Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            studentName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              if (className.isNotEmpty) ...[
                                                Icon(
                                                  Icons.class_,
                                                  size: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  className,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                              if (status.isNotEmpty) ...[
                                                if (className.isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                        ),
                                                    child: Text(
                                                      "•",
                                                      style: TextStyle(
                                                        color: Colors.grey[400],
                                                      ),
                                                    ),
                                                  ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber
                                                        .withAlpha(45),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    status,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.amber,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Color> _getPositionColors(int index) {
    switch (index) {
      case 0:
        return [Colors.amber.shade400, Colors.amber.shade600]; // Gold
      case 1:
        return [Colors.grey.shade400, Colors.grey.shade600]; // Silver
      case 2:
        return [Colors.brown.shade300, Colors.brown.shade500]; // Bronze
      default:
        return [Colors.blue.shade400, Colors.blue.shade600]; // Default
    }
  }
}

// import 'package:acadobs/core/extensions/context_extensions.dart';
// import 'package:acadobs/core/utils/common_shimmer_list.dart';
// import 'package:acadobs/core/utils/custom_error_dialog.dart';
// import 'package:acadobs/core/utils/custom_popup_menu.dart';
// import 'package:acadobs/core/utils/custom_snackbar.dart';
// import 'package:acadobs/core/utils/empty_screen.dart';
// import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
// import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
// import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
// import 'package:acadobs/routes/router_constants.dart';
// import 'package:acadobs/shared/widgets/common_appbar.dart';
// import 'package:acadobs/shared/widgets/profile_tile.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:lucide_icons/lucide_icons.dart';
// import 'package:provider/provider.dart';

// class AchievementDetailsScreen extends StatefulWidget {
//   final int achievementId;
//   final bool forStaff;
//   const AchievementDetailsScreen({
//     super.key,
//     required this.achievementId,
//     required this.forStaff,
//   });

//   @override
//   State<AchievementDetailsScreen> createState() =>
//       _AchievementDetailsScreenState();
// }

// class _AchievementDetailsScreenState extends State<AchievementDetailsScreen> {
//   late AchievementProvider _provider;
//   @override
//   void initState() {
//     super.initState();
//     _provider = context.read<AchievementProvider>();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _provider.fetchSingleAchievement(
//         achievementId: widget.achievementId,
//         forStaff: widget.forStaff,
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: CommonAppBar(
//         title: "Achievement",
//         isBackButton: true,
//         actions: [
//           widget.forStaff
//               ? Consumer<AchievementProvider>(
//                 builder: (context, provider, _) {
//                   return Consumer<AchievementProvider>(
//                     builder: (context, provider, _) {
//                       return CustomPopupMenu(
//                         // showEdit: false,
//                         onEdit: () {
//                           context.pushNamed(
//                             RouteConstants.editAchievement,
//                             extra: provider.singleAchievement,
//                           );
//                         },
//                         onDelete: () {
//                           showConfirmationDialog(
//                             context: context,
//                             title: 'Delete achievement',
//                             content: 'Do you want to delete the achievement?',
//                             onConfirm: () async {
//                               Navigator.of(context).pop();

//                               final ok = await context
//                                   .read<AchievementProvider>()
//                                   .deleteAchievement(
//                                     provider.singleAchievement?.id ?? 0,
//                                   );

//                               if (ok) {
//                                 if (!context.mounted) return;
//                                 CustomSnackbar.show(
//                                   context,
//                                   message: "Achievement deleted",
//                                   type: SnackbarType.success,
//                                 );
//                                 Navigator.pop(context);
//                               } else {
//                                 if (!context.mounted) return;
//                                 CustomErrorDialog.show(
//                                   context,
//                                   "Failed to delete achievement",
//                                 );
//                               }
//                             },
//                           );
//                         },
//                       );
//                     },
//                   );
//                 },
//               )
//               : SizedBox.shrink(),
//         ],
//       ),
//       body: Consumer<AchievementProvider>(
//         builder: (context, provider, _) {
//           final achievement = provider.singleAchievement;

//           if (provider.isLoading && achievement == null) {
//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: commonShimmerList(),
//             );
//           }

//           if (achievement == null) {
//             return emptyScreen(message: 'No Details Found.');
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 226,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFCEFFD3),
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: const Center(
//                     child: Icon(
//                       LucideIcons.filePlus2,
//                       color: Color(0xFF5DD168),
//                       size: 150,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Title
//                 Text(
//                   capitalizeEachWord(achievement.title ?? ""),
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 // Description
//                 Text(
//                   capitalizeEachWord(achievement.description ?? ""),
//                   style: const TextStyle(color: Color(0xFF949494)),
//                 ),

//                 const SizedBox(height: 20),
//                 Text(
//                   "Prizes: ",
//                   style: context.textTheme.bodyMedium!.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 // Students list
//                 Expanded(
//                   child: ListView.builder(
//                     itemCount: achievement.studentAchievements?.length ?? 0,
//                     itemBuilder: (context, index) {
//                       final studentAchievement =
//                           achievement.studentAchievements?[index];
//                       return ProfileTile(
//                         name:
//                             "${studentAchievement?.student?.fullName ?? ""} - ${studentAchievement?.status ?? ""}",
//                         description:
//                             studentAchievement
//                                 ?.student
//                                 ?.classGrade
//                                 ?.classname ??
//                             "",
//                         suffixText: "",
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
