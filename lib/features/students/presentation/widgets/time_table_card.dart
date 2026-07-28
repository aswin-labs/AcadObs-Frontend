import 'package:flutter/material.dart';

class TimeTableCard extends StatelessWidget {
  final int periodnumber;
  final String subject;
  final String description;
  final bool? forStaff;
  const TimeTableCard({
    super.key,
    required this.subject,
    required this.description,
    required this.periodnumber,
    this.forStaff = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 110,
      height: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffECECEC), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECCE),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              periodnumber.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFFA86637),
                fontSize: 15,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Expanded(
            child: Text(
              subject,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),

          // const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.school_outlined,
                size: 15,
                color: Colors.grey.shade700,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
