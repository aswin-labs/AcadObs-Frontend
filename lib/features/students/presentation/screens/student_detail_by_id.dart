// import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/news/presentation/screens/news_full_screen.dart';
import 'package:acadobs/features/notices/widgets/notice_card.dart';

import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';

import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/widgets/create_leave_request_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';

import 'package:acadobs/shared/widgets/common_floating_button.dart';
// import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

class StudentDetailById extends StatefulWidget {
  final int studentId;
  final bool forParent;
  const StudentDetailById({
    super.key,
    required this.studentId,
    required this.forParent,
  });

  @override
  State<StudentDetailById> createState() => _StudentDetailByIdState();
}

class _StudentDetailByIdState extends State<StudentDetailById> {
  late final StudentProvider _studentProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _studentProvider = context.read<StudentProvider>();
    _studentProvider.fetchNoticeByStudentId(studentId: widget.studentId);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_studentProvider.isLoading &&
        _studentProvider.hasMore) {
      _studentProvider.fetchNoticeByStudentId(
        loadMore: true,
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
      body: RefreshIndicator(
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 55,
                ),
                child: Column(
                  children: [
                    Consumer<StudentProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading && provider.notices.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: commonShimmerList(),
                          );
                        }
                        if (provider.notices.isEmpty) {
                          return emptyScreen(
                            message: "No Notices Found",
                            heightMultiplier: 16,
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.notices.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final notices = provider.notices[index];
                            return NoticeCard(
                              icon: Icons.notifications_none,
                              title: notices.title ?? "",
                              date: notices.date,
                              time: DateFormatter.formatDateTime(
                                notices.createdAt,
                              ),
                              onTap: () {
                                context.pushNamed(
                                  RouteConstants.noticedetails,
                                  extra: notices,
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    Consumer<StudentProvider>(
                      builder: (context, provider, _) {
                        return provider.isLoading && provider.hasMore
                            ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                            : const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onRefresh: () async {
          await context
              .read<StudentLeaveRequestProvider>()
              .fetchAllStudentLeaveRequests(studentId: widget.studentId);
        },
      ),

      floatingActionButton: CommonFloatingButton(
        onPressed:
            () => showCreateLeaveRequesBottomSheet(
              context,
              fromTeacherScreen: false,
              studentId: widget.studentId,
            ),
      ),
    );
  }
}
