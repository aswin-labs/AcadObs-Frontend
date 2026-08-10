import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_bottomsheet.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/quick_action_card.dart';
import 'package:acadobs/routes/modules/common_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              onTap: () {
                final params = HomeworkParameters(
                  viewerType: HomeworkViewerType.teacherView,
                );
                context.pushNamed(
                  RouteConstants.homeworkLisitingScreen,
                  extra: params,
                  queryParameters: params.toQueryParameters(),
                );
              },
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
    ],
  );
}
