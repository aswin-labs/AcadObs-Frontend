import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AttendanceCardShimmer extends StatelessWidget {
  const AttendanceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day text shimmer
            Container(width: 100, height: 16, color: Colors.white),
            const SizedBox(height: 16),
            // Date row shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 80, height: 14, color: Colors.white),
                Container(width: 50, height: 14, color: Colors.white),
              ],
            ),
            const SizedBox(height: 20),
            // Period progress shimmer
            Row(
              children: [
                Expanded(child: Container(height: 10, color: Colors.white)),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 10, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            // Period labels shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(width: 20, height: 12, color: Colors.white),
                Container(width: 20, height: 12, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
