import 'package:acadobs/shared/widgets/download_file_card.dart';
import 'package:flutter/material.dart';

class HomeworkPointsViewCard extends StatelessWidget {
  final String studentName;
  final String rollNumber;
  final String? remarks;
  final int points;
  final String? fileName;
  final bool? isSeen;
  final bool showSeenStatus;

  const HomeworkPointsViewCard({
    super.key,
    required this.studentName,
    required this.rollNumber,
    required this.points,
    this.remarks,
    this.fileName,
    this.isSeen,
    this.showSeenStatus = false,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFF0F0F0),
                child: Text(
                  rollNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: Student Name + Seen / Not Seen Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      if (showSeenStatus) ...[
                        const SizedBox(width: 8),
                        _buildSeenBadge(isSeen == true),
                      ],
                    ],
                  ),

                  // Remarks
                  if (remarks != null && remarks!.trim().isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "Remarks: ",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          TextSpan(
                            text: remarks!,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Bottom row: Stars on left, solved file download on right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => Icon(
                            index < safePoints ? Icons.star : Icons.star_border,
                            size: 20,
                            color:
                                index < safePoints
                                    ? Colors.amber
                                    : Colors.grey.shade400,
                          ),
                        ),
                      ),
                      if (fileName != null && fileName!.trim().isNotEmpty)
                        DownloadFileCard(
                          fileName: fileName!,
                          iconOnly: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeenBadge(bool isSeen) {
    final Color bgColor =
        isSeen ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED);
    final Color textColor =
        isSeen ? const Color(0xFF047857) : const Color(0xFFC2410C);
    final Color borderColor =
        isSeen ? const Color(0xFFA7F3D0) : const Color(0xFFFED7AA);
    final IconData icon =
        isSeen ? Icons.visibility_rounded : Icons.visibility_off_rounded;
    final String label = isSeen ? "Viewed" : "Not Viewed";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 0.9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
