import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class TimeTableShimmer extends StatelessWidget {
  const TimeTableShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 9,
        mainAxisSpacing: 8,
        childAspectRatio: 0.68,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circle for index number
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),

                // Subject text placeholder
                Container(height: 16, width: 80, color: Colors.grey.shade400),

                // Icon + teacher name placeholder
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(height: 14, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
