import 'package:flutter/material.dart';

class TimetableBox extends StatelessWidget {
  final int periodNumber;
  final String title;
  final String description;
  final bool isSubstitution;

  const TimetableBox({
    super.key,
    required this.periodNumber,
    required this.title,
    required this.description,
    this.isSubstitution = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:
            isSubstitution
                ? const Color.fromARGB(255, 255, 249, 240)
                : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSubstitution ? Colors.orange.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor:
                isSubstitution ? Colors.orange.shade100 : Colors.amber.shade100,
            child: Text(
              '$periodNumber',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSubstitution ? Colors.orange.shade800 : Colors.brown,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
