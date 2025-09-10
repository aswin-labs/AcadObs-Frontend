// import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/widgets/create_leave_request_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class LeaveLetterScreen extends StatefulWidget {
  final int studentId;
  final bool forParent;
  const LeaveLetterScreen({
    super.key,
    required this.studentId,
    required this.forParent,
  });

  @override
  State<LeaveLetterScreen> createState() => _LeaveLetterScreenState();
}

class _LeaveLetterScreenState extends State<LeaveLetterScreen> {
  late final StudentLeaveRequestProvider _studentLeaveProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _studentLeaveProvider = context.read<StudentLeaveRequestProvider>();
    _studentLeaveProvider.fetchAllStudentLeaveRequests(
      studentId: widget.studentId,
    );
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    final isNearBottom =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200;

    if (isNearBottom &&
        !_studentLeaveProvider.isLoading &&
        _studentLeaveProvider.hasMore) {
      _studentLeaveProvider.fetchAllStudentLeaveRequests(
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
                    // Text('hello'),
                    Consumer<StudentLeaveRequestProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading &&
                            provider.leaveRequests.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: commonShimmerList(),
                          );
                        }
                        if (provider.leaveRequests.isEmpty) {
                          return emptyScreen(
                            message: "No Leave Requsts Found",
                            heightMultiplier: 16,
                          );
                        }
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: provider.leaveRequests.length,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final leave = provider.leaveRequests[index];

                            return ItemCard(
                              title: '${leave.leaveType} leave',
                              description: leave.reason,
                              onTap: () {
                                context.pushNamed(
                                  RouteConstants.studentLeaveLetterScreen,
                                  extra: leave,
                                );
                              },
                              icon: LucideIcons.clock,
                              iconColor: Colors.orange,
                              backgroundColor: Color(0xFFFFF3E0),
                            );
                          },
                        );
                      },
                    ),
                    Consumer<StudentLeaveRequestProvider>(
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

      floatingActionButton:
          widget.forParent
              ? CommonFloatingButton(
                onPressed:
                    () => showCreateLeaveRequesBottomSheet(
                      context,
                      fromTeacherScreen: false,
                      studentId: widget.studentId,
                    ),
              )
              : SizedBox.shrink(),
    );
  }
}
