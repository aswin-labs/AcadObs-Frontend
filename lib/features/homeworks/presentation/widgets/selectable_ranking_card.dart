import 'package:acadobs/features/homeworks/presentation/provider/homeworks_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SelectableRankingCard extends StatelessWidget {
  final String name;
  final String number;
  final int studentId;
  final int point;
  final int homeworkId;
  final bool isSelected;
  final ValueChanged<bool?> onSelectionChanged;

  const SelectableRankingCard({
    super.key,
    required this.name,
    required this.number,
    required this.studentId,
    required this.point,
    required this.homeworkId,
    required this.isSelected,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final rankingProvider = Provider.of<HomeworksProvider>(context);
    final currentPoint = rankingProvider.getPoint(studentId);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE0E0E0),
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Checkbox(
                  value: isSelected,
                  onChanged: onSelectionChanged,
                  activeColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFF0F0F0),
                  child: Text(
                    number,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          if (isSelected) ...[
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                children: List.generate(5, (index) {
                  return IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      index < currentPoint ? Icons.star : Icons.star_border,
                      color:
                          index < currentPoint
                              ? Colors.amber
                              : Colors.grey.shade400,
                      size: 28,
                    ),
                    onPressed: () {
                      rankingProvider.updatePoint(studentId, index + 1);
                    },
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
