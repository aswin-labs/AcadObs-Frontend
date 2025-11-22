import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_bottomsheet.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/quick_action_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Widget buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.assignment_outlined,
                label: 'Homework',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                ),
                onTap: () => context.pushNamed(RouteConstants.homeworks),
              ),
            ),
            Expanded(
              child: QuickActionCard(
                icon: Icons.check_circle_outline,
                label: 'Attendance',
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                onTap: () => showAttendanceBottomSheet(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Consumer<StudentLeaveRequestProvider>(
          builder: (context, provider, _) {
            return QuickActionCard(
              icon: Icons.description_outlined,
              label: 'Student Leave Requests',
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              ),
              notificationCount: provider.leaveNotificationCount,
              onTap: () => context.pushNamed(RouteConstants.studentLeaveLetter),
              isFullWidth: true,
            );
          },
        ),
      ],
    );
  }