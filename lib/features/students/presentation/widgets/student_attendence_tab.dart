import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/students/presentation/widgets/daily_attendance_widget.dart';
import 'package:acadobs/shared/widgets/attendance_card_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    studentProvider = context.read<StudentProvider>();

    _initialDate = DateFormat("yyyy-MM-dd").parse(widget.date);

    studentProvider.fetchAttendanceByDate(
      studentId: widget.studentId,
      date: widget.date,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            Consumer<StudentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const AttendanceCardShimmer();
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
          ],
        ),
      ),
    );
  }
}
