import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';

class ViewingGradeCard extends StatelessWidget {
  final int rollNumber;
  final String name;
  final String mark;
  final bool isAbsent;

  const ViewingGradeCard({
    super.key,
    required this.rollNumber,
    required this.name,
    required this.mark,
    required this.isAbsent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade300),
          ),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 2),
              blurRadius: 1,
              color: Colors.grey.withAlpha(80),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 60,
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFF4F4F4),
                child: Text(
                  rollNumber.toString(),
                  style: const TextStyle(
                    color: Color(0xFF7C7C7C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  capitalizeEachWord(name),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            Container(
              width: 2,
              height: 60,
              color: Colors.grey.shade200,
            ),

            SizedBox(
              width: 60,
              height: 60,
              child: Center(
                child: Text(
                  isAbsent ? '-' : mark,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            Container(
              width: 40,
              height: 60,
              alignment: Alignment.center,
              color: isAbsent
                  ? Colors.red.shade100
                  : Colors.green.shade100,
              child: Text(
                isAbsent ? 'A' : 'P',
                style: TextStyle(
                  color: isAbsent
                      ? Colors.red.shade700
                      : Colors.green.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}