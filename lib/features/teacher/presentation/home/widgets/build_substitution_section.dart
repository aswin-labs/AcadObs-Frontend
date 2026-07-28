import 'package:acadobs/features/students/presentation/widgets/time_table_card.dart';
import 'package:acadobs/features/timetable/presentation/provider/time_table_provider.dart';
import 'package:acadobs/shared/widgets/time_table_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget buildSubstitutionSection(BuildContext context) {
  return Consumer<TimeTableProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return const TimeTableShimmer();
      }

      if (provider.substitution.isEmpty) {
        return const SizedBox.shrink();
      }

      final screenWidth = MediaQuery.sizeOf(context).width;

      final double maxCrossAxisExtent;
      if (screenWidth >= 1200) {
        maxCrossAxisExtent = 250;
      } else if (screenWidth >= 800) {
        maxCrossAxisExtent = 200;
      } else {
        maxCrossAxisExtent = 150;
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.swap_horiz, color: Color(0xFFFF9800), size: 20),
              SizedBox(width: 8),
              Text(
                'Substitution Classes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            padding: EdgeInsets.zero,
            itemCount: provider.substitution.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = provider.substitution[index];

              return TimeTableCard(
                forStaff: true,
                periodnumber: item.timeTable?.periodNumber ?? 0,
                subject: item.subject?.subjectName ?? 'N/A',
                description: item.timeTable?.classGrade?.classname ?? 'N/A',
              );
            },
          ),
        ],
      );
    },
  );
}
