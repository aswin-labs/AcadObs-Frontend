import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:flutter/material.dart';

Widget commonShimmerList({double height = 60, int itemCount = 6}) {
  return ListView.builder(
    padding: EdgeInsets.zero,
    shrinkWrap: true,
    itemCount: itemCount,
    itemBuilder:
        (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: CommonShimmerTile(height: height),
        ),
  );
}
