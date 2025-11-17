import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/detail_screen_args.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SchoolAchievementListing extends StatefulWidget {
  final bool forStaff;
  const SchoolAchievementListing({super.key, required this.forStaff});

  @override
  State<SchoolAchievementListing> createState() =>
      _SchoolAchievementListingState();
}

class _SchoolAchievementListingState extends State<SchoolAchievementListing> {
  late final AchievementProvider _provider;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _provider = context.read<AchievementProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshAllData();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_provider.isLoadingSchool &&
          _provider.hasMoreSchool) {
        _provider.fetchSchoolAchievements(
          loadMore: true,
          forStaff: widget.forStaff,
          limit: 12,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> refreshAllData() async {
    await Future.wait([
      _provider.fetchSchoolAchievements(forStaff: widget.forStaff, limit: 12),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'School Achievements', isBackButton: true),
      body: RefreshIndicator(
        onRefresh: refreshAllData,
        child: Consumer<AchievementProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingSchool &&
                provider.schoolAchievementsAll.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: commonShimmerList(),
              );
            }

            if (provider.schoolAchievementsAll.isEmpty) {
              return emptyScreen(message: 'No Achievements Found.');
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount:
                  provider.schoolAchievementsAll.length +
                  (provider.hasMoreSchool ? 1 : 0),
              itemBuilder: (context, index) {
                // if (index == 0) {
                //   return SizedBox(height: Responsive.height * 3);
                // }

                if (index == provider.schoolAchievementsAll.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final achievement = provider.schoolAchievementsAll[index];

                return ItemCard(
                  icon: Icons.workspace_premium,
                  backgroundColor: Colors.blue.shade50,
                  iconColor: Colors.blue.shade500,

                  title: achievement.title ?? "Untitled",
                  description: achievement.description ?? "No description",
                  onTap: () {
                    context.pushNamed(
                      RouteConstants.achievementDetailsScreen,
                      extra: DetailScreenArgs(
                        id: achievement.id ?? 0,
                        forStaff: widget.forStaff,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
