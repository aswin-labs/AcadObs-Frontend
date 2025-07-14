import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileContainerShimmer extends StatelessWidget {
  const ProfileContainerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final double containerHeight = MediaQuery.of(context).size.height * 0.09;
    const double avatarRadius = 34.0;

    Widget shimmerBox({double? width, double? height, BorderRadius? radius}) {
      return Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: radius ?? BorderRadius.circular(4),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Top container with avatar
        Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: [
            Container(
              height: containerHeight,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            Positioned(
              bottom: -avatarRadius * 0.7,
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.height * 3),

        // Name placeholder
        shimmerBox(
          width: 120,
          height: 20,
          radius: BorderRadius.circular(4),
        ),
        SizedBox(height: Responsive.height * 1),

        // Description placeholder
        shimmerBox(
          width: 80,
          height: 18,
          radius: BorderRadius.circular(4),
        ),
        SizedBox(height: Responsive.height * 2),

        // Stats container
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (_) => Column(
                children: [
                  shimmerBox(width: 24, height: 20),
                  const SizedBox(height: 6),
                  shimmerBox(width: 40, height: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
