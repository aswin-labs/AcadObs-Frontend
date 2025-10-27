import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class StudentLeavesScreen extends StatefulWidget {
  const StudentLeavesScreen({super.key});

  @override
  State<StudentLeavesScreen> createState() => _StudentLeavesScreenState();
}

class _StudentLeavesScreenState extends State<StudentLeavesScreen> {
  final ScrollController _scrollController = ScrollController();
  late StudentLeaveRequestProvider studentLeaveProvider;
  @override
  void initState() {
    super.initState();
    studentLeaveProvider = context.read<StudentLeaveRequestProvider>();

    studentLeaveProvider.getStudentLeaveRequestsForClassTeacher(
      forceRefresh: true,
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !studentLeaveProvider.isLoading &&
          studentLeaveProvider.hasMore) {
        studentLeaveProvider.getStudentLeaveRequestsForClassTeacher(
          loadMore: true,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Student Leaves", isBackButton: true),
      body: RefreshIndicator(
        onRefresh:
            () => studentLeaveProvider.getStudentLeaveRequestsForClassTeacher(
              forceRefresh: true,
            ),
        child: Consumer<StudentLeaveRequestProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.studentLeaves.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: commonShimmerList(),
              );
            }

            if (provider.studentLeaves.isEmpty) {
              return emptyScreen(message: 'No Homeworks Found.');
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount:
                  provider.studentLeaves.length + (provider.hasMore ? 2 : 1),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(height: Responsive.height * 3);
                }

                if (index == provider.studentLeaves.length + 1) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final grouped = provider.studentLeaves[index - 1];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatDateTime(
                        grouped.date ?? DateTime.now(),
                      ),
                      style: context.textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: Responsive.height * 1),
                    ...grouped.requests!.map((leave) {
                      final leaveStatusStyle = getLeaveStatusStyle(
                        leave.status ?? "",
                      );
                      return ItemCard(
                        title: leave.student?.fullName ?? "",
                        description: DateFormatter.formatDateTime(
                          leave.fromDate ?? DateTime.now(),
                        ),
                        status: leave.status ?? "",
                        backgroundColor: leaveStatusStyle.backgroundColor,
                        icon: leaveStatusStyle.icon,
                        iconColor: leaveStatusStyle.iconColor,
                        onTap: () {
                          final updatedLeave = LeaveModel(
                            forStudentLeavePermission: true,
                            fromDate: leave.fromDate,
                            toDate: leave.toDate,
                            status: leave.status,
                            id: leave.id,
                            attachment: leave.attachment,
                            leaveDuration: leave.leaveDuration,
                            leaveType: leave.leaveType,
                            reason: leave.reason,
                            approvedBy: leave.approvedBy,
                            halfSection: leave.halfSection,
                          );
                          context.pushNamed(
                            RouteConstants.studentLeaveLetterScreen,
                            extra: updatedLeave,
                          );
                        },
                      );
                    }),
                    SizedBox(height: Responsive.height * 2),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
