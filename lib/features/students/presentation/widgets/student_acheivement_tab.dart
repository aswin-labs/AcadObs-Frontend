import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/detail_screen_args.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StudentAcheivementTab extends StatefulWidget {
  final int studentId;
  final bool forStaff;

  const StudentAcheivementTab({
    super.key,
    required this.studentId,
    this.forStaff = false,
  });

  @override
  State<StudentAcheivementTab> createState() => _StudentAcheivementTabState();
}

class _StudentAcheivementTabState extends State<StudentAcheivementTab> {
  late final AchievementProvider _provider;
  final ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _provider = context.read<AchievementProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.fetchAchievementsByStudentId(
        studentId: widget.studentId,
        forStaff: widget.forStaff,
      );
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_provider.isLoadingStudent &&
          _provider.hasMoreStudent) {
        _provider.fetchAchievementsByStudentId(
          studentId: widget.studentId,
          forStaff: widget.forStaff,
          loadMore: true,
        );
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
      body: RefreshIndicator(
        onRefresh: () => _provider.fetchAchievementsByStudentId(studentId: widget.studentId, forStaff: widget.forStaff),
        child: Consumer<AchievementProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingStudent &&
                provider.studentAchievements.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: commonShimmerList(),
              );
            }

            if (provider.studentAchievements.isEmpty) {
              return emptyScreen(message: 'No Achievements Found.');
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 55),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount:
                  provider.studentAchievements.length +
                  (provider.hasMoreTeacher ? 1 : 0),
              itemBuilder: (context, index) {
                // if (index == 0) {
                //   return SizedBox(height: Responsive.height * 3);
                // }

                if (index == provider.studentAchievements.length ) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final achievement = provider.studentAchievements[index];

                return ItemCard(
                  title: achievement.achievement?.title ?? "Untitled",
                  description:
                      achievement.achievement?.description ?? "No description",
                  onTap: () {
                    context.pushNamed(
                      RouteConstants.achievementDetailsScreen,
                      extra: DetailScreenArgs(
                        id: achievement.achievement?.id ?? 0,
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
