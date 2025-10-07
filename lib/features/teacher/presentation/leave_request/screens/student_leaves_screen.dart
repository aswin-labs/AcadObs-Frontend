import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/leave_status_style.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<StudentLeaveRequestProvider>()
          .getStudentLeaveRequestsForClassTeacher(forceRefresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "Student Leaves", isBackButton: true),
      body: Consumer<StudentLeaveRequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.leaveRequests.isEmpty) {
            return commonShimmerList();
          } else if (provider.leaveRequests.isEmpty) {
            return emptyScreen(message: "No Leave Requests available");
          }

          final List<LeaveModel> leaves = provider.leaveRequests;

          return RefreshIndicator(
            onRefresh:
                () => provider.getStudentLeaveRequestsForClassTeacher(
                  forceRefresh: true,
                ),
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (!provider.isLoading &&
                    scrollNotification.metrics.pixels ==
                        scrollNotification.metrics.maxScrollExtent &&
                    provider.currentPage < provider.totalPages) {
                  provider.getStudentLeaveRequestsForClassTeacher(
                    loadMore: true,
                  );
                }
                return false;
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: leaves.length,
                itemBuilder: (context, index) {
                  final leave = leaves[index];
                  final leaveRequest = provider.leaveRequests[index];
                  final leaveStatusStyle = getLeaveStatusStyle(
                    leaveRequest.status ?? "",
                  );
                  return ItemCard(
                    title:
                        "${leave.student?.fullName ?? ""} - ${leave.leaveType} Leave",
                    description: leave.reason ?? "",
                    status: leaveRequest.status ?? "",
                    backgroundColor: leaveStatusStyle.backgroundColor,
                    icon: leaveStatusStyle.icon,
                    iconColor: leaveStatusStyle.iconColor,
                    onTap: () {
                      context.pushNamed(
                        RouteConstants.studentLeaveLetterScreen,
                        extra: leave,
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
