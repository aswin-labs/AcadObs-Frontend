import 'package:flutter/material.dart';

class CommonButton extends StatelessWidget {
  final Widget widget;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double? buttonHeight;
  const CommonButton({
    super.key,
    required this.onPressed,
    required this.widget,
    this.backgroundColor = Colors.black,
    this.buttonHeight = 55,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: backgroundColor),
        onPressed: onPressed,
        child: widget,
      ),
    );
  }
}
