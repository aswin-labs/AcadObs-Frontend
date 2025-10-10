import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TimeTableListCard extends StatelessWidget {
  final String subject;
  final String teacher;
  final String status;
  final String classname;
  final double bottomRadius;
  final double topRadius;
  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final int periodNumber;

  final void Function() onTap;

  const TimeTableListCard({
    super.key,
    required this.subject,
    required this.teacher,
    this.status = "",
    required this.classname,
    required this.onTap,
    this.backgroundColor = const Color(0xFFFFECCE),
    this.iconColor = const Color(0xFFA86637),
    this.icon = LucideIcons.clipboardList,
    this.bottomRadius = 8,
    this.topRadius = 8,
    required this.periodNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(bottomRadius),
              bottomRight: Radius.circular(bottomRadius),
              topLeft: Radius.circular(topRadius),
              topRight: Radius.circular(topRadius),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: backgroundColor,
                        child: Icon(icon, color: iconColor),
                      ),
                      SizedBox(height: 5),
                      //time container
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Color(0xFFFFECCE),
                        ),
                        child: Text(
                          '$periodNumber',
                          style: TextStyle(color: Color(0xFFA86637)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizeEachWord(subject),
                        style: context.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),

                      SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.person, color: Colors.black, size: 18),
                          SizedBox(width: 4),
                          Text(
                            teacher,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 2),

                      //classname
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.black,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            classname,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                capitalizeEachWord(status),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
