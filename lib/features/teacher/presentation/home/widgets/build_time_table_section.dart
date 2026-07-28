import 'package:acadobs/features/students/presentation/widgets/time_table_card.dart';
import 'package:acadobs/features/timetable/presentation/provider/time_table_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/time_table_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Widget buildTimeTableSection(BuildContext context) {
  return Consumer<TimeTableProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return const TimeTableShimmer();
      }

      if (provider.timetableForStaff.isEmpty) {
        return const SizedBox.shrink();
      }
      final textScale = MediaQuery.textScalerOf(
        context,
      ).scale(1.0).clamp(1.0, 1.3);

      final aspectRatio = textScale > 1.15 ? 0.70 : 0.85;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.schedule, color: Color(0xFF2196F3), size: 20),
              SizedBox(width: 8),
              Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              TextButton(
                onPressed: () {
                  context.pushNamed(
                    RouteConstants.timeTableDayTabStaff,
                    extra: true,
                  );
                },
                child: Text('View'),
              ),
            ],
          ),
          SizedBox(height: 10),
          GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: provider.timetableForStaff.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: aspectRatio,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = provider.timetableForStaff[index];
              return TimeTableCard(
                forStaff: true,
                periodnumber: item.periodNumber ?? 0,
                subject: item.subject?.subjectName ?? "N/A",
                description: item.classGrade?.classname ?? "N/A",
              );
            },
          ),
        ],
      );
    },
  );
}
