import 'dart:developer';

import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/students/presentation/widgets/daily_attendance_widget.dart';
import 'package:acadobs/features/students/presentation/widgets/time_table_card.dart';
import 'package:acadobs/features/timetable/presentation/provider/time_table_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/attendance_card_shimmer.dart';
import 'package:acadobs/shared/widgets/time_table_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentAttendenceTab extends StatefulWidget {
  final int studentId;
  final String date;

  const StudentAttendenceTab({
    super.key,
    required this.studentId,
    required this.date,
  });

  @override
  State<StudentAttendenceTab> createState() => _StudentAttendenceTabState();
}

class _StudentAttendenceTabState extends State<StudentAttendenceTab> {
  late StudentProvider studentProvider;
  late DateTime _initialDate;
  late TimeTableProvider timeTableProvider;

  @override
  void initState() {
    super.initState();
    studentProvider = context.read<StudentProvider>();
    timeTableProvider = context.read<TimeTableProvider>();

    _initialDate = DateFormat("yyyy-MM-dd").parse(widget.date);
    log(
      "Fetching timetable for studentId: ${widget.studentId}, date: ${widget.date}",
    );

    studentProvider.resetAttendance();
    studentProvider.fetchAttendanceByDate(
      studentId: widget.studentId,
      date: DateFormat("yyyy-MM-dd").format(_initialDate),
    );

    timeTableProvider.fetchTimeTable(
      studentId: widget.studentId,
      forStaff: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 60),
              Consumer<StudentProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const AttendanceCardShimmer();
                  }
                  if (provider.totalPeriod == 0 && provider.status.isEmpty) {
                    // Add this block
                    return const Center(
                      child: Text("No attendance data available"),
                    );
                  }
                  return DailyAttendanceWidget(
                    totalPeriodCount: provider.totalPeriod,
                    initialDate: _initialDate,
                    statuses: provider.status,
                    onDateChanged: (newDate) {
                      provider.fetchAttendanceByDate(
                        studentId: widget.studentId,
                        date: newDate,
                      );
                      setState(() {
                        _initialDate = DateFormat("yyyy-MM-dd").parse(newDate);
                      });
                    },
                  );
                },
              ),

              SizedBox(height: 20),

              Row(
                children: [
                  Text(
                    "Today TimeTable",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(
                        RouteConstants.timeTableDayTab,
                        extra: widget.studentId,
                      );
                    },
                    child: Text("View"),
                  ),
                ],
              ),

              Consumer<TimeTableProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading) {
                    return const Center(child: TimeTableShimmer());
                  }

                  if (provider.timetable.isEmpty) {
                    return emptyScreen(message: "No Time Table Avaliable");
                  }

                  return GridView.builder(
                    itemCount: provider.timetable.length,
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),

                    itemBuilder: (context, index) {
                      final item = provider.timetable[index];
                      return TimeTableCard(
                        periodnumber: item.periodNumber ?? 0,
                        subject: item.subject?.subjectName ?? "",
                        description: item.user?.name ?? "",
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
