import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/students/presentation/widgets/daily_attendance_widget.dart';
import 'package:acadobs/shared/widgets/attendance_card_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentAttendenceTab extends StatefulWidget {
  final int studentId;
  final String date;
  final bool forStaff;
  const StudentAttendenceTab({
    super.key,
    required this.studentId,
    required this.date,
    required this.forStaff,
  });

  @override
  State<StudentAttendenceTab> createState() => _StudentAttendenceTabState();
}

class _StudentAttendenceTabState extends State<StudentAttendenceTab> {
  late StudentProvider studentProvider;
  late DateTime _initialDate;

  @override
  void initState() {
    super.initState();
    studentProvider = context.read<StudentProvider>();

    _initialDate = DateFormat("yyyy-MM-dd").parse(widget.date);
    studentProvider.resetAttendance();
    studentProvider.fetchAttendanceByDate(
      studentId: widget.studentId,
      forStaff: widget.forStaff,
      date: DateFormat("yyyy-MM-dd").format(_initialDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<StudentProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const AttendanceCardShimmer();
            }
            if (provider.attendanceCount == 0 && provider.status.isEmpty) {
              // Add this block
              return DailyAttendanceWidget(
                totalAttendanceCount: 2,
                initialDate: _initialDate,
                statuses: provider.status,
                onDateChanged: (newDate) {
                  provider.fetchAttendanceByDate(
                    studentId: widget.studentId,
                    date: newDate,
                    forStaff: widget.forStaff,
                  );
                  setState(() {
                    _initialDate = DateFormat("yyyy-MM-dd").parse(newDate);
                  });
                },
              );
            }
            return DailyAttendanceWidget(
              totalAttendanceCount: provider.attendanceCount,
              initialDate: _initialDate,
              statuses: provider.status,
              onDateChanged: (newDate) {
                provider.fetchAttendanceByDate(
                  studentId: widget.studentId,
                  date: newDate,
                  forStaff: widget.forStaff,
                );
                setState(() {
                  _initialDate = DateFormat("yyyy-MM-dd").parse(newDate);
                });
              },
            );
          },
        ),

        SizedBox(height: 20),
      ],
    );
  }
}
