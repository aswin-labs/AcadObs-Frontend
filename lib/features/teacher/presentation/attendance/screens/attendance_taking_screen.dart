import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_upload_model.dart';
import 'package:acadobs/features/teacher/presentation/attendance/provider/attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_shimmer_widget.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_status_card.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_summarycard.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_taking_widget.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:acadobs/shared/widgets/restore_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceTakingScreen extends StatefulWidget {
  final AttendanceUploadModel attendance;
  const AttendanceTakingScreen({super.key, required this.attendance});

  @override
  State<AttendanceTakingScreen> createState() => _AttendanceTakingScreenState();
}

class _AttendanceTakingScreenState extends State<AttendanceTakingScreen> {
  late AttendanceProvider attendanceProvider;
  @override
  void initState() {
    attendanceProvider = context.read<AttendanceProvider>();
    attendanceProvider.fetchAttendanceByClassIdAndDate(
      context: context,
      classId: widget.attendance.classId,
      date: widget.attendance.date,
      period: widget.attendance.period,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      attendanceProvider.clearAllAttendance();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: widget.attendance.className,
        isBackButton: true,
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
                      return provider.isAttendanceAlreadyTaken ||
                              provider.isLoading
                          ? SizedBox.shrink()
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  context
                                      .read<AttendanceProvider>()
                                      .markAllPresent();
                                },
                                child: Container(
                                  width: Responsive.width * 30,
                                  padding: EdgeInsets.all(8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Set All Present",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          );
                    },
                  ),
                  SizedBox(height: Responsive.height * 1),
                  Consumer<AttendanceProvider>(
                    builder: (context, provider, _) {
                      final attendance = provider.recordedAttendance;
                      final students = provider.students;
                      final inTrash = attendance?.trash;

                      if (provider.isLoading || provider.isRestoring) {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 10,
                          itemBuilder:
                              (context, index) =>
                                  const AttendanceShimmerWidget(),
                        );
                      }

                      if (students.isEmpty &&
                          provider.isAttendanceAlreadyTaken) {
                        return Column(
                          children: [
                            AttendanceSummaryCard(
                              title:
                                  inTrash == true
                                      ? "This attendance entry was deleted"
                                      : "Attendance Already Recorded",
                              backgroundColor:
                                  inTrash == true
                                      ? Colors.red.shade50
                                      : Colors.white,
                              borderColor:
                                  inTrash == true ? Colors.red : Colors.white,
                              className: widget.attendance.className,
                              date: DateFormatter.formatDateString(
                                widget.attendance.date,
                              ),
                              period: widget.attendance.period.toString(),
                              subject:
                                  attendance?.subject?.subjectName ??
                                  "Not Specified",
                              teacherName:
                                  attendance?.user?.name ?? "Not Specified",
                              teacherRole:
                                  attendance?.user?.role ?? "Not Specified",
                            ),
                            SizedBox(height: Responsive.height * 2),
                            inTrash == true
                                ? RestoreButton(
                                  onPressed: () async {
                                    final provider =
                                        context.read<AttendanceProvider>();

                                    final isRestored = await provider
                                        .restoreAttendance(
                                          context: context,
                                          attendanceId:
                                              provider.recordedAttendance?.id ??
                                              0,
                                        );

                                    if (isRestored) {
                                      if (!context.mounted) return;
                                      await provider
                                          .fetchAttendanceByClassIdAndDate(
                                            context: context,
                                            forRestoring: true,
                                            classId: widget.attendance.classId,
                                            date: widget.attendance.date,
                                            period: widget.attendance.period,
                                          );
                                    }
                                  },
                                )
                                : SizedBox.shrink(),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: attendance?.studentRecords?.length,
                              itemBuilder: (context, index) {
                                final student =
                                    attendance?.studentRecords?[index];
                                // final isLeaveApproved =
                                //     student.studentRecords?.isNotEmpty;
                                // final remarks =
                                //     student?.remarks == null
                                //         ? ""
                                //         : student?.remarks ?? "";
                                return AttendanceStatusCard(
                                  rollNo: student?.student?.rollNumber ?? 0,
                                  name: student?.student?.fullName ?? "",
                                  status: student?.status ?? "",
                                );
                                // AttendanceTakingWidget(
                                //   // isLeaveApproved: isLeaveApproved,
                                //   remarks: remarks,
                                //   currentStatus: student?.status ?? "",
                                //   alreadyTaken: true,
                                //   studentId: student?.id ?? 0,
                                //   rollNo: student?.student?.rollNumber ?? 0,
                                //   studentName: student?.student?.fullName ?? "",
                                // );
                              },
                            ),
                          ],
                        );
                      }

                      if (students.isEmpty &&
                          provider.isAttendanceAlreadyTaken == false) {
                        return emptyScreen(message: "No Students Found");
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.students.length,
                        itemBuilder: (context, index) {
                          final student = provider.students[index];
                          final isLeaveApproved =
                              student.studentRecords?.isNotEmpty;

                          return AttendanceTakingWidget(
                            isLeaveApproved: isLeaveApproved,
                            alreadyTaken: isLeaveApproved ?? false,
                            studentId: student.id,
                            rollNo: student.rollNumber ?? 0,
                            studentName: student.fullName,
                          );
                        },
                      );
                    },
                  ),
                  SizedBox(height: Responsive.height * 4),
                  Consumer<AttendanceProvider>(
                    builder: (context, provider, _) {
                      return provider.students.isNotEmpty
                          ? CommonButton(
                            onPressed:
                                () => context
                                    .read<AttendanceProvider>()
                                    .submitAttendance(
                                      context: context,
                                      classId: widget.attendance.classId,
                                      period: widget.attendance.period,
                                      date: widget.attendance.date,
                                      subjectId: widget.attendance.subjectId,
                                    ),
                            widget:
                                provider.isLoadingTwo
                                    ? ButtonLoading()
                                    : Text("Submit"),
                          )
                          : SizedBox.shrink();
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
