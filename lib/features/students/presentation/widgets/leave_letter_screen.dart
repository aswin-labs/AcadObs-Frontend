// import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/widgets/create_leave_request_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LeaveLetterScreen extends StatefulWidget {
  final int studentId;
  final bool forStaff;
  const LeaveLetterScreen({
    super.key,
    required this.studentId,
    required this.forStaff,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _studentLeaveProvider.setFilter("all");
    });
    _studentLeaveProvider.fetchAllStudentLeaveRequests(
      studentId: widget.studentId,
      forStaff: widget.forStaff,
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
        forStaff: widget.forStaff,
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
        onRefresh: () async {
          await context
              .read<StudentLeaveRequestProvider>()
              .fetchAllStudentLeaveRequests(
                studentId: widget.studentId,
                forStaff: widget.forStaff,
                forceRefresh: true,
              );
        },
        child: Consumer<StudentLeaveRequestProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Filter Dropdown
                SliverAppBar(
                  toolbarHeight: 100,
                  pinned: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: MediaQuery.of(context).padding.top + 36,
                      bottom: 4,
                    ),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 220),
                        child: DropdownButtonFormField<String>(
                          isDense: true,
                          decoration: InputDecoration(
                            labelText: "Filter by Status",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          value: provider.filterStatus,
                          items: const [
                            DropdownMenuItem(value: "all", child: Text("All")),
                            DropdownMenuItem(
                              value: "approved",
                              child: Text("Approved"),
                            ),
                            DropdownMenuItem(
                              value: "pending",
                              child: Text("Pending"),
                            ),
                            DropdownMenuItem(
                              value: "rejected",
                              child: Text("Rejected"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              provider.setFilter(value);
                              // Automatically refresh list when filter changes
                              provider.fetchAllStudentLeaveRequests(
                                studentId: widget.studentId,
                                forStaff: widget.forStaff,
                                forceRefresh: true,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Shimmer / Empty / List
                if (provider.isLoading && provider.leaveRequests.isEmpty)
                  SliverFillRemaining(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: commonShimmerList(),
                    ),
                  )
                else if (provider.leaveRequests.isEmpty)
                  SliverFillRemaining(
                    child: emptyScreen(
                      message: "No Leave Requests Found",
                      heightMultiplier: 16,
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index < provider.leaveRequests.length) {
                          final leave = provider.leaveRequests[index];
                          final leaveStatusStyle = getLeaveStatusStyle(
                            leave.status ?? "",
                          );

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ItemCard(
                              title: '${leave.leaveType} leave',
                              description: leave.reason ?? "",
                              status: leave.status ?? "",
                              date: DateFormatter.formatDateString(
                                leave.fromDate.toString(),
                              ),
                              onTap: () {
                                context.pushNamed(
                                  RouteConstants.studentLeaveLetterScreen,
                                  extra: leave,
                                );
                              },
                              icon: leaveStatusStyle.icon,
                              iconColor: leaveStatusStyle.iconColor,
                              backgroundColor: leaveStatusStyle.backgroundColor,
                            ),
                          );
                        } else {
                          // Loader row at bottom
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                      childCount:
                          provider.leaveRequests.length +
                          (provider.isLoading && provider.hasMore ? 1 : 0),
                    ),
                  ),
              ],
            );
          },
        ),
      ),

      floatingActionButton:
          widget.forStaff
              ? CommonFloatingButton(
                onPressed:
                    () => showCreateLeaveRequesBottomSheet(
                      context,
                      fromTeacherScreen: false,
                      studentId: widget.studentId,
                    ),
              )
              : const SizedBox.shrink(),
    );
  }
}
