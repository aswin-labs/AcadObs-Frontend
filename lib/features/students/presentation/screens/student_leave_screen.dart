// import 'dart:developer';

import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/widgets/create_leave_request_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StudentLeaveScreen extends StatefulWidget {
  final int studentId;
  final bool forStaff;
  const StudentLeaveScreen({
    super.key,
    required this.studentId,
    required this.forStaff,
  });

  @override
  State<StudentLeaveScreen> createState() => _StudentLeaveScreenState();
}

class _StudentLeaveScreenState extends State<StudentLeaveScreen> {
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
      floatingActionButton:
          widget.forStaff
              ? const SizedBox.shrink()
              : CommonFloatingButton(
                onPressed:
                    () => showCreateLeaveRequesBottomSheet(
                      context,
                      fromTeacherScreen: false,
                      studentId: widget.studentId,
                    ),
              ),

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

        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔵 AppBar
                CommonAppBar(title: 'Leave request', isBackButton: true),

                const SizedBox(height: 10),

                // 🔵 Filter
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 220,
                    child: Consumer<StudentLeaveRequestProvider>(
                      builder: (context, provider, _) {
                        return DropdownButtonFormField<String>(
                          isDense: true,
                          value: provider.filterStatus,
                          decoration: InputDecoration(
                            labelText: "Filter by Status",
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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

                              provider.fetchAllStudentLeaveRequests(
                                studentId: widget.studentId,
                                forStaff: widget.forStaff,
                                forceRefresh: true,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 🔵 Content
                Consumer<StudentLeaveRequestProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.leaveRequests.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: commonShimmerList(),
                      );
                    }

                    if (provider.leaveRequests.isEmpty) {
                      return emptyScreen(
                        message: "No Leave Requests Found",
                        heightMultiplier: 16,
                      );
                    }

                    return Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.leaveRequests.length,
                          itemBuilder: (context, index) {
                            final leave = provider.leaveRequests[index];
                            final style = getLeaveStatusStyle(
                              leave.status ?? "",
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
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
                                icon: style.icon,
                                iconColor: style.iconColor,
                                backgroundColor: style.backgroundColor,
                              ),
                            );
                          },
                        ),

                        if (provider.isLoading && provider.hasMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
