import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/button_loading.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/attendance_initial_data.dart';
import 'package:acadobs/features/teacher/presentation/attendance/provider/attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_shimmer_widget.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_summarycard.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_taking_widget.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceTakingScreen extends StatefulWidget {
  final AttendanceInitialData attendanceInitialData;
  const AttendanceTakingScreen({
    super.key,
    required this.attendanceInitialData,
  });

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
      classId: widget.attendanceInitialData.classId,
      date: widget.attendanceInitialData.date,
      period: widget.attendanceInitialData.period,
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
        title: widget.attendanceInitialData.className,
        isBackButton: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(EdgeInsets.only(top:Responsive.height * 2)),
              child: Column(
                children: [
                  Consumer<AttendanceProvider>(
                        builder: (context, value, child) {
                        return Row(
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
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  "Set All Present",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                      SizedBox(height: Responsive.height * 1),
                  Consumer<AttendanceProvider>(
                    builder: (context, provider, _) {
                      final data = provider.attendanceRecordedData;
                      final students = provider.students;
                      final status = data?.status;
                      final attendance = data?.attendance;

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

                      if (students.isEmpty && status == 'not_recorded') {
                        return emptyScreen(message: "No Students Found");
                      }

                      if (students.isEmpty && status == 'recorded') {
                        return AttendanceSummaryCard(
                          className: widget.attendanceInitialData.className,
                          date: DateFormatter.formatDateString(
                            widget.attendanceInitialData.date,
                          ),
                          period:
                              widget.attendanceInitialData.period.toString(),
                          subject: attendance?.subject ?? "Not Specified",
                          teacherName: attendance?.user.name ?? "Not Specified",
                          teacherRole: attendance?.user.role ?? "Not Specified",
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: provider.students.length,
                        itemBuilder: (context, index) {
                          final student = provider.students[index];
                          return AttendanceTakingWidget(
                            studentId: student.id,
                            rollNo: student.rollNumber,
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
                                      classId:
                                          widget.attendanceInitialData.classId,
                                      period:
                                          widget.attendanceInitialData.period,
                                      date: widget.attendanceInitialData.date,
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
