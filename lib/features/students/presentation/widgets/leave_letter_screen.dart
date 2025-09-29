// import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
import 'package:acadobs/core/utils/responsive.dart';
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
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(
                              width: Responsive.width * 30,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    labelText: "Filter by Status",
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        12,
                                      ), // rounded corners
                                    ),

                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  value:
                                      provider.leaveRequests.isEmpty
                                          ? "all"
                                          : provider.leaveRequests.first.status
                                                  ?.toLowerCase() ??
                                              "all",
                                  items: const [
                                    DropdownMenuItem(
                                      value: "all",
                                      child: Text(
                                        "All",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "approved",
                                      child: Text(
                                        "Approved",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "pending",
                                      child: Text(
                                        "Pending",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: "rejected",
                                      child: Text(
                                        "Rejected",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      provider.setFilter(value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

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
                            final leaveStatusStyle = getLeaveStatusStyle(
                              leave.status ?? "",
                            );

                            return ItemCard(
                              title: '${leave.leaveType} leave',
                              description: leave.reason,
                              status: leave.status ?? "",
                              date: leave.fromDate,
                              onTap: () {
                                context.pushNamed(
                                  RouteConstants.studentLeaveLetterScreen,
                                  extra: leave,
                                );
                              },
                              icon: leaveStatusStyle.icon,
                              iconColor: leaveStatusStyle.iconColor,
                              backgroundColor: leaveStatusStyle.backgroundColor,
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
