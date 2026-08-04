import 'dart:developer';

import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/features/homework/presentation/widgets/ranking_card.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeworkRankingScreen extends StatefulWidget {
  final HomeworkRankScreenParameters homeworkParams;
  const HomeworkRankingScreen({super.key, required this.homeworkParams});

  @override
  State<HomeworkRankingScreen> createState() => _HomeworkRankingScreenState();
}

class _HomeworkRankingScreenState extends State<HomeworkRankingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log(
        "studentHomeworkStatus: ${widget.homeworkParams.homework.studentHomeworkStatus}",
      );

      final provider = context.read<HomeworkProvider>();
      for (var status
          in widget.homeworkParams.homework.studentHomeworkStatus ?? []) {
        final id = status.student?.id;
        if (id != null) {
          if (status.points != null) {
            provider.updatePoint(id, status.points!);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homework = widget.homeworkParams.homework;
    final dueDate = homework.dueDate;

    Future<void> submitRankings() async {
      final provider = context.read<HomeworkProvider>();
      final studentPoints = provider.studentRankingsList;

      if (studentPoints.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please assign at least one point')),
        );
        return;
      }

      await provider.homeworkRanking(
        context: context,
        homeworkId: homework.id ?? 0,
        assignments: studentPoints,
      );

      if (!context.mounted) return;

      Navigator.pop(context);
      Navigator.pop(context);
    }

    return Scaffold(
      extendBody: true,
      appBar: CommonAppBar(
        title:
            widget.homeworkParams.forClassTeacher
                ? "Homework Details"
                : 'Homework Ranking',
        isBackButton: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          widget.homeworkParams.forClassTeacher
              ? SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _detailRow(
                          Icons.title_rounded,
                          "Title",
                          homework.title ?? "No title",
                        ),

                        const SizedBox(height: 14),
                        _detailRow(
                          Icons.subject_outlined,
                          "Subject",
                          homework.subject?.subjectName ?? "Not Mentioned",
                        ),

                        const SizedBox(height: 14),

                        _detailRow(
                          Icons.person_outline,
                          "Recorded By",
                          homework.user?.name ?? "Not Mentioned",
                        ),

                        const SizedBox(height: 14),

                        _detailRow(
                          Icons.description_outlined,
                          "Description",
                          homework.description ?? "No description available",
                          isDescription: true,
                        ),
                        const SizedBox(height: 14),

                        _detailRow(
                          Icons.calendar_month_outlined,
                          "Due Date",
                          dueDate != null
                              ? DateFormat('dd MMM yyyy').format(dueDate)
                              : "Not Mentioned",
                        ),
                      ],
                    ),
                  ),
                ),
              )
              : SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withAlpha(77),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(51),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Due Date',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dueDate != null
                              ? DateFormat('dd MMM yyyy').format(dueDate)
                              : 'Due date not mentioned',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

          // Student count and ranking label
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 18,
                          color: Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${homework.studentHomeworkStatus?.length ?? 0} Students',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.emoji_events_outlined,
                          size: 18,
                          color: Color(0xFF6366F1),
                        ),
                        SizedBox(width: 6),
                        Text(
                          widget.homeworkParams.forClassTeacher
                              ? 'View Points'
                              : 'Rank Students',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Students list
          Consumer<HomeworkProvider>(
            builder: (context, provider, _) {
              final studentStatuses =
                  provider.singleHomework?.studentHomeworkStatus ??
                  homework.studentHomeworkStatus ??
                  [];

              if (studentStatuses.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('No students found')),
                );
              }

              return SliverPadding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: widget.homeworkParams.forClassTeacher ? 24 : 110,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final studentStatus = studentStatuses[index];
                    final studentId = studentStatus.student?.id ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RankingCard(
                        studentId: studentId,
                        name: studentStatus.student?.fullName ?? '',
                        number:
                            studentStatus.student?.rollNumber?.toString() ?? '',
                        point: provider.getPoint(studentId),
                        homeworkId: studentStatus.id ?? 0,
                        remark: studentStatus.remark ?? '',
                        forViewing: !widget.homeworkParams.forClassTeacher,
                      ),
                    );
                  }, childCount: studentStatuses.length),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:
          widget.homeworkParams.forClassTeacher
              ? null
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Consumer<HomeworkProvider>(
                    builder: (context, provider, _) {
                      return CommonButton(
                        onPressed:
                            provider.isLoadingTwo ? null : submitRankings,
                        widget:
                            provider.isLoadingTwo
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Submit Rankings',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                      );
                    },
                  ),
                ),
              ),
    );
  }

  Widget _detailRow(
    IconData icon,
    String label,
    String value, {
    bool isDescription = false,
  }) {
    return Row(
      crossAxisAlignment:
          isDescription ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6366F1)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
