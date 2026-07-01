import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';

import 'package:acadobs/features/notices/presentation/widgets/notice_card.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StudentNoticeScreen extends StatefulWidget {
  final int studentId;
  final bool forStaff;
  const StudentNoticeScreen({
    super.key,
    required this.studentId,
    required this.forStaff,
  });

  @override
  State<StudentNoticeScreen> createState() => _StudentNoticeScreenState();
}

class _StudentNoticeScreenState extends State<StudentNoticeScreen> {
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<StudentProvider>().fetchNoticeByStudentId(
            studentId: widget.studentId,
            forceRefresh: true,
          );
        },
        child: Consumer<StudentProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                SliverToBoxAdapter(
                  child: CommonAppBar(title: 'Notices', isBackButton: true),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                if (provider.isLoading && provider.notices.isEmpty)
                  SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 90),
                      child: commonShimmerList(),
                    ),
                  )
                else if (provider.notices.isEmpty)
                  SliverFillRemaining(
                    child: emptyScreen(
                      message: "No Notices Found",
                      heightMultiplier: 16,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < provider.notices.length) {
                          final notice = provider.notices[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: NoticeCard(
                              icon: Icons.notifications_none,
                              title: notice.title ?? "",
                              date: notice.date,
                              time: TimeFormatter.formatTime(notice.createdAt),
                              onTap: () {
                                context.pushNamed(
                                  RouteConstants.noticedetails,
                                  extra: notice,
                                );
                              },
                            ),
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                      childCount:
                          provider.notices.length +
                          (provider.isLoading && provider.hasMore ? 1 : 0),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
