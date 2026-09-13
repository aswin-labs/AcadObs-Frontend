import 'package:acadobs/features/tracking/data/models/today_transportation_model.dart';
import 'package:flutter/material.dart';

class StudentStopCompletedCard extends StatelessWidget {
  final TransportationStop stop;
  final StudentTransportationInfo? student;
  final StudentStopStatus? studentStatus;
  final TodayTransportationModel transportation;

  static const _emeraldSuccess = Color(0xFF10B981);
  static const _slateText = Color(0xFF0F172A);
  static const _slateMuted = Color(0xFF64748B);

  const StudentStopCompletedCard({
    super.key,
    required this.stop,
    required this.student,
    required this.studentStatus,
    required this.transportation,
  });

  @override
  Widget build(BuildContext context) {
    final statusStr = studentStatus?.status?.toLowerCase() ?? "arrived";
    final isPicked = statusStr == "picked";
    final isDropped = statusStr == "dropped";
    final isNotPicked = statusStr == "not_picked";
    final isNotDropped = statusStr == "not_dropped";

    Color cardBg;
    Color borderColor;
    Color headerBg;
    Color statusBadgeBg;
    Color statusBadgeText;
    IconData statusIcon;
    String statusTitle;
    String statusSubtitle;

    if (isPicked) {
      cardBg = const Color(0xFFF0FDF4);
      borderColor = _emeraldSuccess;
      headerBg = const Color(0xFFDCFCE7);
      statusBadgeBg = const Color(0xFF10B981);
      statusBadgeText = Colors.white;
      statusIcon = Icons.how_to_reg_rounded;
      statusTitle = "PICKED UP";
      statusSubtitle = "Child safely boarded the vehicle at this stop";
    } else if (isDropped) {
      cardBg = const Color(0xFFF0FDF4);
      borderColor = _emeraldSuccess;
      headerBg = const Color(0xFFDCFCE7);
      statusBadgeBg = const Color(0xFF10B981);
      statusBadgeText = Colors.white;
      statusIcon = Icons.verified_user_rounded;
      statusTitle = "DROPPED OFF";
      statusSubtitle = "Child safely reached destination";
    } else if (isNotPicked) {
      cardBg = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFEF4444);
      headerBg = const Color(0xFFFEE2E2);
      statusBadgeBg = const Color(0xFFDC2626);
      statusBadgeText = Colors.white;
      statusIcon = Icons.cancel_rounded;
      statusTitle = "NOT PICKED";
      statusSubtitle = "Child was not boarded at this stop";
    } else if (isNotDropped) {
      cardBg = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFF59E0B);
      headerBg = const Color(0xFFFEF3C7);
      statusBadgeBg = const Color(0xFFD97706);
      statusBadgeText = Colors.white;
      statusIcon = Icons.warning_rounded;
      statusTitle = "NOT DROPPED";
      statusSubtitle = "Child is still on board";
    } else {
      cardBg = const Color(0xFFF0FDF4);
      borderColor = _emeraldSuccess;
      headerBg = const Color(0xFFDCFCE7);
      statusBadgeBg = _emeraldSuccess;
      statusBadgeText = Colors.white;
      statusIcon = Icons.check_circle_rounded;
      statusTitle = "COMPLETED";
      statusSubtitle = "Bus has reached your child's assigned stop";
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withAlpha(50),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Header with fix for the 17px overflow
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: headerBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(statusIcon, color: borderColor, size: 16),
                      const SizedBox(width: 6),
                      const Flexible(
                        child: Text(
                          "CHILD STATUS",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            color: _slateText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusBadgeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusTitle,
                    style: TextStyle(
                      color: statusBadgeText,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Body with student and route details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Name and Reg No Row
                Row(
                  children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: borderColor.withAlpha(40),
                      child: Text(
                        (student?.fullName?.isNotEmpty == true)
                            ? student!.fullName![0].toUpperCase()
                            : "S",
                        style: TextStyle(
                          color: borderColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student?.fullName ?? "Your Child",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _slateText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (student?.regNo != null)
                            Text(
                              "Registration No: ${student!.regNo}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: _slateMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Subtitle / message
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: borderColor.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: borderColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          statusSubtitle,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: borderColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Vehicle & Stop confirmation footer with safe overflow handling
                Row(
                  children: [
                    const Icon(
                      Icons.place_rounded,
                      size: 13,
                      color: _slateMuted,
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        stop.stopName ?? "Stop",
                        style: const TextStyle(
                          fontSize: 11,
                          color: _slateMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.directions_bus_rounded,
                      size: 13,
                      color: _slateMuted,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        transportation.route?.vehicle?.vehicleNumber ??
                            "Bus On Route",
                        style: const TextStyle(
                          fontSize: 11,
                          color: _slateMuted,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
