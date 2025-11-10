import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/students/presentation/provider/student_achievement_provider.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
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
  late final StudentAchievementProvider _studentAchievementProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _studentAchievementProvider = context.read<StudentAchievementProvider>();
    _studentAchievementProvider.fetchAchievementByStudentId(
      forStaff: widget.forStaff,
      studentId: widget.studentId,
    );
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_studentAchievementProvider.isLoading &&
        _studentAchievementProvider.hasMore) {
      _studentAchievementProvider.fetchAchievementByStudentId(
        forStaff: widget.forStaff,
        studentId: widget.studentId,
      );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 55),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Consumer<StudentAchievementProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.achievementModel.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: commonShimmerList(),
                  );
                }

                if (provider.achievementModel.isEmpty) {
                  return emptyScreen(
                    message: 'No Achievement Found',
                    heightMultiplier: 16,
                  );
                }

                return ListView.builder(
                  itemCount: provider.achievementModel.length,
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final achievement = provider.achievementModel[index];
                    return ItemCard(
                      title: achievement.achievement?.title ?? "",
                      description: achievement.achievement?.description ?? " ",
                      onTap: () {
                        // context.pushNamed(
                        //   RouteConstants.achievementDetailsScreen,
                        //   extra: achievement,
                        // );
                      },
                    );
                  },
                );
              },
            ),
            Consumer<StudentAchievementProvider>(
              builder: (context, provider, _) {
                return provider.isLoading && provider.hasMore
                    ? Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                    : const SizedBox();
              },
            ),
            SizedBox(height: Responsive.height * 4),
          ],
        ),
      ),
    );
  }
}
