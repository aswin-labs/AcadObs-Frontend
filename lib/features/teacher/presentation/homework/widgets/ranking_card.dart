import 'package:flutter/material.dart';

class RankingCard extends StatelessWidget {
  final String name;
  final String number;
  const RankingCard({super.key, required this.name, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: const Color(0xFFE0E0E0)), // light border
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
                    number,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black,
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
                      return Icon(
                        index < 3 ? Icons.star : Icons.star_border,
                        color: index < 3 ? Colors.amber : Colors.grey.shade400,
                        size: 30,
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
                Container(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
