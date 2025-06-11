import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';

class CustomContainer extends StatelessWidget {
  final Color color;
  final String text;
  final IconData icon;
  final VoidCallback ontap;
  final bool isCenterText;

  const CustomContainer({
    super.key,
    required this.color,
    required this.text,
    this.icon = Icons.dashboard_customize_outlined,
    required this.ontap,
    this.isCenterText = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Container(
        padding: EdgeInsets.all(Responsive.height * 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment:
              isCenterText ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.width * 3),
              child: Icon(
                icon,
                color: Colors.white,
              ),
            ),
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
