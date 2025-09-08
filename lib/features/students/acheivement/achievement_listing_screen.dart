// import 'package:acadobs/core/constants/app_constants.dart';
import 'dart:developer';

import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/achievements/presentaion/provider/acheivement_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_button2.dart';
// import 'package:acadobs/shared/widgets/common_floating_button2.dart';
import 'package:acadobs/shared/widgets/item_card.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
// import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class AchievementListingScreen extends StatefulWidget {
  const AchievementListingScreen({super.key});

  @override
  State<AchievementListingScreen> createState() =>
      _AchievementListingScreenState();
}

class _AchievementListingScreenState extends State<AchievementListingScreen> {
  late final AchievementProvider _achievementProvider;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _achievementProvider = context.read<AchievementProvider>();
    log(
      'AchievementListingScreen.initState - provider hash: ${_achievementProvider.hashCode}',
    );
    _achievementProvider.fetchAllAchievements();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_achievementProvider.isLoading &&
        _achievementProvider.hasMore) {
      _achievementProvider.fetchAllAchievements(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'My Achievements', isBackButton: true),
      body: RefreshIndicator(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: context.paddingHorizontal.add(
                  EdgeInsets.only(top: Responsive.height * 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AchievementProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading &&
                            provider.achievements.isEmpty) {
                          return commonShimmerList();
                        }
                        if (provider.achievements.isEmpty) {
                          return emptyScreen(
                            message:
                                'No Achievements Found. Error: ${provider.error ?? "None"}',
                          );
                        }
                        return Column(
                          children: [
                            if (provider.todayAchievement.isNotEmpty) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Today",
                                  // style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.todayAchievement.length,
                                itemBuilder: (context, index) {
                                  final achievement =
                                      provider.todayAchievement[index];
                                  return ItemCard(
                                    title: achievement.title ?? "Untitled",
                                    description:
                                        achievement.description ??
                                        "No description",
                                    onTap: () {
                                      context.pushNamed(
                                        RouteConstants.achievementDetailsScreen,
                                        extra: achievement,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],

                            if (provider.yesterdayAchievement.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Yesterday",
                                  // style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.yesterdayAchievement.length,
                                itemBuilder: (context, index) {
                                  final achievement =
                                      provider.yesterdayAchievement[index];
                                  return ItemCard(
                                    title: achievement.title ?? "Untitled",
                                    description:
                                        achievement.description ??
                                        "No description",
                                    onTap: () {
                                      context.pushNamed(
                                        RouteConstants.achievementDetailsScreen,
                                        extra: achievement,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                            if (provider.earlierAchievement.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Earlier",
                                  // style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.earlierAchievement.length,
                                itemBuilder: (context, index) {
                                  final achievement =
                                      provider.earlierAchievement[index];
                                  return ItemCard(
                                    title: achievement.title ?? "Untitled",
                                    description:
                                        achievement.description ??
                                        "No description",
                                    onTap: () {
                                      context.pushNamed(
                                        RouteConstants.achievementDetailsScreen,
                                        extra: achievement,
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ],
                        );
                        // return ListView.builder(
                        //   shrinkWrap: true,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   itemCount: provider.achievements.length,
                        //   itemBuilder: (context, index) {
                        //     final achievement = provider.achievements[index];

                        //     return ItemCard(
                        //       title: achievement.title ?? "Untitled",
                        //       description:
                        //           achievement.description ?? "No description",
                        //       onTap: () {
                        //         context.pushNamed(
                        //           RouteConstants.achievementDetailsScreen,
                        //           extra: achievement,
                        //         );
                        //       },
                        //     );
                        //   },
                        // );
                      },
                    ),
                    Consumer<AchievementProvider>(
                      builder: (context, provider, _) {
                        return provider.isLoading && provider.hasMore
                            ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox();
                      },
                    ),
                    SizedBox(height: Responsive.height * 4),
                  ],
                ),
              ),
            ),
          ],
        ),
        onRefresh: () async {
          await context.read<AchievementProvider>().fetchAllAchievements(
            forceRefresh: true,
          );
        },
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
