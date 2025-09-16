import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/features/homework/presentation/widgets/homework_remark.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RankingCard extends StatefulWidget {
  final String name;
  final String number;
  final int studentId;
  final int point;
  final int homeworkId;
  final String remark;
  const RankingCard({
    super.key,
    required this.name,
    required this.number,
    required this.studentId,
    required this.point,
    required this.homeworkId,
    required this.remark,
  });

  @override
  State<RankingCard> createState() => _RankingCardState();
}

class _RankingCardState extends State<RankingCard> {

  @override
  Widget build(BuildContext context) {
    final rankingProvider = Provider.of<HomeworkProvider>(context);
    final currentPoint = rankingProvider.getPoint(widget.studentId);
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          // Top Row: Avatar and Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFF0F0F0),
                  child: Text(
                    widget.number,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacer(),
                Expanded(
                  child: Text(
                    widget.remark,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          // Bottom Row: Stars and Chat icon
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
            ),
            height: 60,
            child: Row(
              children: [
                // Stars section
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < currentPoint ? Icons.star : Icons.star_border,
                          color:
                              index < currentPoint
                                  ? Colors.amber
                                  : Colors.grey.shade400,
                          size: 30,
                        ),
                        onPressed: () {
                          rankingProvider.updatePoint(
                            widget.studentId,
                            index + 1,
                          );
                        },
                      );
                    }),
                  ),
                ),

                const Spacer(),

                // Vertical divider
                Container(
                  width: 1,
                  height: double.infinity,
                  color: const Color(0xFFE0E0E0),
                ),

                // Chat Icon
                GestureDetector(
                  onTap:
                      () => showDialog(
                        context: context,
                        builder:
                            (context) => HomeworkRemark(
                              name: widget.name,
                              homeworkId: widget.homeworkId,
                            ),
                      ),
                  child: Container(
                    width: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(9),
                      ),
                    ),

                    child: const Icon(Icons.message_outlined, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
