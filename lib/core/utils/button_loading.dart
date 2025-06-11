import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class ButtonLoading extends StatelessWidget {
  final Color? color;
  final double sizeMultiplier;

  const ButtonLoading({
    super.key,
    this.color = Colors.white,
    this.sizeMultiplier = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: Responsive.height * sizeMultiplier,
        height: Responsive.height * 2,
        child: LoadingIndicator(
          indicatorType: Indicator.ballPulse,
          colors: [color!],
          strokeWidth: 1,
          backgroundColor: Colors.transparent,
          pathBackgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
