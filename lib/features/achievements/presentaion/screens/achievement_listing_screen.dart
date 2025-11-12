import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/detail_screen_args.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_button2.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AchievementListingScreen extends StatefulWidget {
  const AchievementListingScreen({super.key});

  @override
  State<AchievementListingScreen> createState() =>
      _AchievementListingScreenState();
}

class _AchievementListingScreenState extends State<AchievementListingScreen> {
  late final AchievementProvider _provider;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _provider = context.read<AchievementProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchAchievementsAddedByTeacher();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_provider.isLoadingTeacher &&
          _provider.hasMoreTeacher) {
        _provider.fetchAchievementsAddedByTeacher(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Student Achievements', isBackButton: true),
      body: RefreshIndicator(
        onRefresh: () => _provider.fetchAchievementsAddedByTeacher(),
        child: Consumer<AchievementProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingTeacher &&
                provider.teacherAchievements.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: commonShimmerList(),
              );
            }

            if (provider.teacherAchievements.isEmpty) {
              return emptyScreen(message: 'No Achievements Found.');
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount:
                  provider.teacherAchievements.length +
                  (provider.hasMoreTeacher ? 2 : 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(height: Responsive.height * 3);
                }

                if (index == provider.teacherAchievements.length + 1) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final achievement = provider.teacherAchievements[index - 1];

                return ItemCard(
                  title: achievement.title ?? "Untitled",
                  description: achievement.description ?? "No description",
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
      ),

      floatingActionButton: CommonFloatingButton2(
        onPressed: () {
          context.pushNamed(RouteConstants.addAchievements);
        },
        icon: LucideIcons.plus,
      ),
    );
  }
}
