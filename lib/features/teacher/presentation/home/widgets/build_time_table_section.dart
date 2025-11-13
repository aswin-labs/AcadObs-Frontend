import 'package:acadobs/features/students/presentation/widgets/time_table_card.dart';
import 'package:acadobs/features/timetable/presentation/provider/time_table_provider.dart';
import 'package:acadobs/shared/widgets/time_table_shimmer.dart';
import 'package:flutter/material.dart';
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

      final screenWidth = MediaQuery.of(context).size.width;

      double maxCrossAxisExtent;
      if (screenWidth >= 1200) {
        maxCrossAxisExtent = 250;
      } else if (screenWidth >= 800) {
        maxCrossAxisExtent = 200; // tablet
      } else {
        maxCrossAxisExtent = 150; // phone
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
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
            ],
          ),

          GridView.builder(
            itemCount: provider.timetableForStaff.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
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
