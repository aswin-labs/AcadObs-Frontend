import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class CustomNameContainer extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomNameContainer({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: Responsive.height * 3),
        ),
        child: Text(
          text,
          style: context.textTheme.bodyLarge!.copyWith(
            color: const Color(0xff555556),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
