import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class CustomNameContainer extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double horizontalWidth;
  const CustomNameContainer({
    super.key,
    required this.text,
    required this.onPressed,
    this.horizontalWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(
            vertical: Responsive.height * 3,
            horizontal: Responsive.width * horizontalWidth,
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: const Color(0xff555556),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
