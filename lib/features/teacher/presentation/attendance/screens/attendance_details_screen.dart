import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/teacher/data/models/attendance_by_teacher_model.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_taking_widget.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';

class AttendanceDetailsScreen extends StatelessWidget {
  final AttendanceByTeacher attendanceByTeacher;
  const AttendanceDetailsScreen({super.key, required this.attendanceByTeacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: attendanceByTeacher.classDetails.classname,
        isBackButton: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: context.paddingHorizontal.add(
                EdgeInsets.only(top: Responsive.height * 2),
              ),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      final studentData =
                          attendanceByTeacher.attendanceMarkeds[index];
                      final student = studentData.student;
                      return AttendanceTakingWidget(
                        studentId: student.id,
                        rollNo: student.rollNumber ?? 0,
                        studentName: student.fullName,
                        alreadyTaken: true,
                        currentStatus: studentData.status,
                        remarks: studentData.remarks,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
