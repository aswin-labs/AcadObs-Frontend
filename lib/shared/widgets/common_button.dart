import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final Widget widget;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double minButtonHeight;

  const CommonButton({
    super.key,
    required this.onPressed,
    required this.widget,
    this.backgroundColor = Colors.black,
    this.minButtonHeight = 55,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minButtonHeight),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          minimumSize: Size(double.infinity, minButtonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: widget,
      ),
    );
  }
}
