import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonShimmerTile extends StatelessWidget {
  final double height;
  const CommonShimmerTile({super.key, this.height =50});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            height: height,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
          ),
          SizedBox(
            height: 2,
            width: double.infinity,
          ),   
        ],
      ),
    );
  }
}
