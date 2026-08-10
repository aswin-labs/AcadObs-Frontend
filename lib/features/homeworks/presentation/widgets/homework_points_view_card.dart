import 'package:acadobs/shared/widgets/download_file_card.dart';
import 'package:flutter/material.dart';

class HomeworkPointsViewCard extends StatelessWidget {
  final String studentName;
  final String rollNumber;
  final String? remarks;
  final int points;
  final String? fileName;

  const HomeworkPointsViewCard({
    super.key,
    required this.studentName,
    required this.rollNumber,
    required this.points,
    this.remarks,
    this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final safePoints = points.clamp(0, 5);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFF0F0F0),
              child: Text(
                rollNumber,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    studentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  if (remarks != null && remarks!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          "Remarks: ",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,

                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          remarks!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 8),

                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < safePoints ? Icons.star : Icons.star_border,
                        size: 22,
                        color:
                            index < safePoints
                                ? Colors.amber
                                : Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (fileName != null) ...[
              const SizedBox(width: 10),
              DownloadFileCard(fileName: fileName ?? "", iconOnly: true),
            ],
          ],
        ),
      ),
    );
  }
}
