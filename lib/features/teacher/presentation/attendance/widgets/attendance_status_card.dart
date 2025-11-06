import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';

class AttendanceStatusCard extends StatelessWidget {
  final int rollNo;
  final String name;
  final String status; // e.g. "Present", "Absent", "Late"
  final Color? statusColor; // Optional custom color

  const AttendanceStatusCard({
    super.key,
    required this.rollNo,
    required this.name,
    required this.status,
    this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        statusColor ??
        (status.toLowerCase() == "present"
            ? Colors.green
            : status.toLowerCase() == "absent"
            ? Colors.red
            : Colors.orange);

    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 197, 196, 196),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                rollNo.toString(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withValues(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                capitalizeEachWord(status),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
