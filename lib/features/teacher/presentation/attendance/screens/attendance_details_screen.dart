import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/custom_popup_menu.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/core/utils/show_confirmation_dialog.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_model.dart';
import 'package:acadobs/features/teacher/presentation/attendance/provider/attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_shimmer_widget.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_taking_widget.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AttendanceDetailsScreen extends StatefulWidget {
  final AttendanceModel attendance;
  const AttendanceDetailsScreen({super.key, required this.attendance});

  @override
  State<AttendanceDetailsScreen> createState() =>
      _AttendanceDetailsScreenState();
}

class _AttendanceDetailsScreenState extends State<AttendanceDetailsScreen> {
  late AttendanceProvider attendanceProvider;
  @override
  void initState() {
    attendanceProvider = context.read<AttendanceProvider>();
    attendanceProvider.fetchAttendanceById(attendanceId: widget.attendance.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title:
            "${widget.attendance.classDetails?.classname} - Period ${widget.attendance.period}",
        isBackButton: true,
        actions: [
          Consumer<AttendanceProvider>(
            builder: (context, provider, _) {
              return CustomPopupMenu(
                onEdit:
                    () => context.pushNamed(
                      RouteConstants.editAttendance,
                      extra: provider.recordedAttendance,
                    ),
                onDelete:
                    () => showConfirmationDialog(
                      context: context,
                      title: 'Delete Attendance',
                      content:
                          'Are you sure you want to delete this attendance?',
                      onConfirm: () {
                        provider.deleteAttendance(
                          context,
                          attendanceId: widget.attendance.id,
                        );
                      },
                    ),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Column(
                children: [
                  Consumer<AttendanceProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 10,
                          itemBuilder:
                              (context, index) =>
                                  const AttendanceShimmerWidget(),
                        );
                      }
                      if (provider.recordedAttendance == null) {
                        return emptyScreen(message: "No Records Found");
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:
                            provider.recordedAttendance?.studentRecords?.length,
                        itemBuilder: (context, index) {
                          final studentData =
                              provider
                                  .recordedAttendance
                                  ?.studentRecords?[index];
                          final student = studentData?.student;
                          final isLeaveApproved =
                              studentData?.remarks == "Full-day Leave approved";
                          return AttendanceTakingWidget(
                            studentId: student?.id ?? 0,
                            rollNo: student?.rollNumber ?? 0,
                            studentName: student?.fullName ?? "",
                            alreadyTaken: true,
                            currentStatus: studentData?.status ?? "",
                            remarks:
                                isLeaveApproved
                                    ? "Approved"
                                    : studentData?.remarks,
                            isLeaveApproved: isLeaveApproved,
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: Responsive.height * 6),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
