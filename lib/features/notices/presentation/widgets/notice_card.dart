import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';

class NoticeCard extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;
  final String time;
  final double bottomRadius;
  final double topRadius;
  final Color backgroundColor;
  final void Function() onTap;

  const NoticeCard({
    super.key,
    required this.title,
    required this.date,
    required this.icon,
    required this.time,
    this.backgroundColor = const Color(0xFFE6F3FF),
    this.bottomRadius = 12,
    this.topRadius = 12,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(bottomRadius),
              bottomRight: Radius.circular(bottomRadius),
              topLeft: Radius.circular(topRadius),
              topRight: Radius.circular(topRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(38),
                spreadRadius: 2,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: backgroundColor,
                    child: Icon(icon, color: const Color(0xFF1E88E5), size: 28),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizeEachWord(title),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F3FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF1E88E5).withAlpha(77),
                          ),
                        ),
                        child: Text(
                          date,
                          style: TextStyle(
                            color: const Color(0xFF1E88E5),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
