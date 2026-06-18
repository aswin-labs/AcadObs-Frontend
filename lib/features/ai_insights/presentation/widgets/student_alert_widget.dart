import 'package:flutter/material.dart';

class StudentAlertWidget extends StatelessWidget {
  const StudentAlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withAlpha(35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Alert Summary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff102A43),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Critical interventions required across three domains.",
                      style: TextStyle(fontSize: 13, color: Color(0xff829AB1)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red),
                ),
                child: const Icon(
                  Icons.priority_high,
                  size: 14,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _alertCard(
            icon: Icons.calendar_month,
            iconBg: const Color(0xfffff0f1),
            iconColor: Colors.red,
            title: "Severe Attendance Gap",
            subtitle:
                " Most absences are in the morning blocks (8:00 AM – 10:00 AM).",
            badge: "40% Absence",
            badgeColor: Colors.red,
            progress: true,
          ),

          const SizedBox(height: 16),

          _alertCard(
            icon: Icons.attach_money,
            iconBg: const Color(0xfffffae6),
            iconColor: Colors.orange,
            title: "Fee Overdue",
            subtitle:
                "Second quarter tuition remains unpaid. Final notice sent to registered guardian on Oct 13.",
            badge: "2 Months",
            badgeColor: Colors.orange,
          ),

          const SizedBox(height: 16),

          _alertCard(
            icon: Icons.trending_down,
            iconBg: const Color(0xfffff5eb),
            iconColor: Colors.deepOrange,
            title: "Academic Decline",
            subtitle:
                "Significant drop in Science and Mathematics compared to the previous assessment cycle.",
            badge: "-12% Shift",
            badgeColor: Colors.deepOrange,
          ),
        ],
      ),
    );
  }

  Widget _alertCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    bool progress = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withAlpha(35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: iconColor),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff102A43),
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withAlpha(18),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: badgeColor.withAlpha(45)),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Color(0xff486581),
                  ),
                ),

                if (progress) ...[
                  const SizedBox(height: 12),

                  Container(
                    height: 4,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey.withAlpha(35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
