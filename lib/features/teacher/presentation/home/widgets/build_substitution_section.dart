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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz, color: Color(0xFFFF9800), size: 20),
              const SizedBox(width: 8),
              Text(
                "Substitution Classes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: provider.substitution.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = provider.substitution[index];
                return TimeTableCard(
                  forStaff: true,
                  periodnumber: item.timeTable?.periodNumber ?? 0,
                  subject: item.subject?.subjectName ?? "",
                  description: item.timeTable?.classGrade?.classname ?? "",
                );
              },
            ),
          ),
        ],
      );
    },
  );
}