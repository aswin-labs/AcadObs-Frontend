import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class StudentHomeworkPage extends StatefulWidget {
  final bool forParent;
  final int studentId;
  final int guardianIdForChat;
  final String guardianNameForChat;
  const StudentHomeworkPage({
    super.key,
    required this.forParent,
    required this.studentId,
    required this.guardianIdForChat,
    required this.guardianNameForChat,
  });

  @override
  State<StudentHomeworkPage> createState() => _StudentHomeworkPageState();
}

class _StudentHomeworkPageState extends State<StudentHomeworkPage> {
  late final HomeworkProvider _homeworkProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _homeworkProvider = context.read<HomeworkProvider>();
    _homeworkProvider.fetchHomeworksByStudentId(
      forParent: widget.forParent,
      studentId: widget.studentId,
    );
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_homeworkProvider.isLoading &&
        _homeworkProvider.hasMoreForStudent) {
      _homeworkProvider.fetchHomeworksByStudentId(
        forParent: widget.forParent,
        studentId: widget.studentId,
        loadMore: true,
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
      body: Consumer<HomeworkProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.studentHomeworks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 90),
              child: commonShimmerList(),
            );
          }

          if (provider.studentHomeworks.isEmpty) {
            return emptyScreen(
              message: 'No Homeworks Found.',
              heightMultiplier: 16,
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 90),
            physics: const BouncingScrollPhysics(),
            itemCount:
                provider.studentHomeworks.length +
                (provider.isLoading && provider.hasMoreForStudent ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < provider.studentHomeworks.length) {
                final homework = provider.studentHomeworks[index];
                return ItemCard(
                  title: homework.homework?.title ?? "N/A",
                  description: DateFormatter.formatDateTime(
                    homework.homework?.dueDate ?? DateTime.now(),
                  ),
                  onTap: () {
                    log((homework.homework?.subject).toString());
                    final homeworkItem = HomeworkModel(
                      forStudent: true,
                      title: homework.homework?.title ?? "N/A",
                      description: homework.homework?.description ?? "N/A",
                      dueDate: homework.homework?.dueDate,
                      studentHomeworkId: homework.id,
                      studentPoints: homework.points,
                      forParent: widget.forParent,
                      guardianIdForChat: widget.guardianIdForChat,
                      guardianNameForChat: widget.guardianNameForChat,
                      user: homework.homework?.user,
                      subject: homework.homework?.subject,
                    );
                    context.pushNamed(
                      RouteConstants.homeworkDetails,
                      extra: homeworkItem,
                    );
                  },
                  icon: LucideIcons.clipboardList,
                  iconColor: const Color(0xFFB14F6F),
                  backgroundColor: const Color(0xFFFFCEDE),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          );
        },
      ),
    );
  }
}
