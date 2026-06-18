import 'package:flutter/material.dart';

class OverallPerformanceWidget extends StatelessWidget {
  const OverallPerformanceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Status row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Leaf / plant icon
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Color(0xFF16A34A),
                        size: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Stable',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                // Trending up arrow
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFF16A34A),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),

          // Metrics Row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left metric: Attendance
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Performance',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '92%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: -1,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: 0.92,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFE5E7EB),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Vertical divider
                Container(width: 1, color: const Color(0xFFF3F4F6)),

                // Right metric: Academic Risk
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Academic Risk',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Low Risk',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF16A34A),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Based on current trends and participation levels.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF9CA3AF),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
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
