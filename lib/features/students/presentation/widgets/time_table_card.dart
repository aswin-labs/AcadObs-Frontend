import 'package:flutter/material.dart';

class TimeTableCard extends StatelessWidget {
  final int periodnumber;
  final String subject;
  final String teacher;
  const TimeTableCard({
    super.key,
    required this.subject,
    required this.teacher,
    required this.periodnumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, spreadRadius: 2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Color(0xFFFFECCE),
              ),
              child: Text(periodnumber.toString(), style: TextStyle(color: Color(0xFFA86637))),
            ),
            const SizedBox(height: 8),
            Text(
              subject,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 4),

                Expanded(
                  child: Text(
                    teacher,
                    style: TextStyle(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
