import 'package:flutter/material.dart';

class ScrollableName extends StatelessWidget {
  final String studentName;
  const ScrollableName({super.key, required this.studentName});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Text(
          studentName,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
