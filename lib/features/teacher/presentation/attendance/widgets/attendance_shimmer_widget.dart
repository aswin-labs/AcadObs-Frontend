import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AttendanceShimmerWidget extends StatelessWidget {
  const AttendanceShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  // Circle Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Name Text Placeholder
                  Expanded(
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom: 3 Buttons with spacing
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  _shimmerButton(leftRadius: 8, rightRadius: 0),
                  const SizedBox(width: 4),
                  _shimmerButton(leftRadius: 0, rightRadius: 0),
                  const SizedBox(width: 4),
                  _shimmerButton(leftRadius: 0, rightRadius: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerButton(
      {required double leftRadius, required double rightRadius}) {
    return Expanded(
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(leftRadius),
            bottomRight: Radius.circular(rightRadius),
          ),
          border: Border.all(color: const Color(0xFFCCCCCC)),
        ),
      ),
    );
  }
}
