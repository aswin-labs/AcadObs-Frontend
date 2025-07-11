import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AttendanceSummaryCard extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color borderColor;
  final String className;
  final String period;
  final String date;
  final String subject;
  final String teacherName;
  final String teacherRole;

  const AttendanceSummaryCard({
    super.key,
    required this.title,
    required this.backgroundColor,
     required this.borderColor,
    required this.className,
    required this.date,
    required this.period,
    required this.subject,
    required this.teacherName,
    required this.teacherRole,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final fontSize = width * 0.04;
    final iconSize = width * 0.05;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.05),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: context.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          SizedBox(height: Responsive.height * 2),
          _buildRow(
            context,
            LucideIcons.layers,
            "Class",
            className,
            iconSize,
            fontSize,
          ),
          _buildRow(
            context,
            LucideIcons.calendar,
            "Date",
            date,
            iconSize,
            fontSize,
          ),
          _buildRow(
            context,
            LucideIcons.clock,
            "Period",
            period,
            iconSize,
            fontSize,
          ),
          _buildRow(
            context,
            LucideIcons.bookOpen,
            "Subject",
            subject,
            iconSize,
            fontSize,
          ),
          _buildRow(
            context,
            LucideIcons.user,
            "Teacher",
            teacherName,
            iconSize,
            fontSize,
          ),
          _buildRow(
            context,
            LucideIcons.badgeCheck,
            "Role",
            teacherRole,
            iconSize,
            fontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    double iconSize,
    double fontSize,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: iconSize, color: Colors.grey[700]),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label: ",
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),

                children: [
                  TextSpan(
                    text: capitalizeEachWord(value),
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
