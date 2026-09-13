import 'package:acadobs/features/tracking/data/models/today_transportation_model.dart';
import 'package:acadobs/features/tracking/presentation/widgets/student_stop_completed_card.dart';
import 'package:flutter/material.dart';

class RouteTimelineTile extends StatelessWidget {
  final TransportationStop stop;
  final int index;
  final bool isArrived;
  final bool isStudentStop;
  final bool isCurrentBusLocation;
  final bool isFirst;
  final bool isLast;
  final bool prevArrived;
  final bool nextArrived;
  final TodayTransportationModel transportation;
  final StudentTransportationInfo? currentStudent;

  static const _navyLight = Color(0xFF2563EB);
  static const _emeraldSuccess = Color(0xFF10B981);
  static const _emeraldDark = Color(0xFF065F46);
  static const _emeraldBg = Color(0xFFECFDF5);
  static const _slateText = Color(0xFF0F172A);
  static const _slateMuted = Color(0xFF64748B);
  static const _trackUpcoming = Color(0xFFCBD5E1);

  const RouteTimelineTile({
    super.key,
    required this.stop,
    required this.index,
    required this.isArrived,
    required this.isStudentStop,
    required this.isCurrentBusLocation,
    required this.isFirst,
    required this.isLast,
    required this.prevArrived,
    required this.nextArrived,
    required this.transportation,
    required this.currentStudent,
  });

  @override
  Widget build(BuildContext context) {
    final topTrackColor =
        (prevArrived && isArrived) ? _emeraldSuccess : _trackUpcoming;
    final bottomTrackColor =
        (isArrived && nextArrived) ? _emeraldSuccess : _trackUpcoming;

    final studentStatus = transportation.getStudentStatusForStop(
      stop.id,
      currentStudent?.id,
    );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Railway/Transit Track Column ──
          SizedBox(
            width: 48,
            child: Column(
              children: [
                // Upper Track Segment
                Container(
                  width: 3.5,
                  height: 22,
                  color: isFirst ? Colors.transparent : topTrackColor,
                ),

                // Station Node
                _buildStationNode(),

                // Lower Track Segment
                Expanded(
                  child: Container(
                    width: 3.5,
                    color: isLast ? Colors.transparent : bottomTrackColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Stop Content & Cards ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStationCard(),

                  // If student's stop AND arrived: recognizable expanded details container
                  if (isStudentStop && isArrived) ...[
                    const SizedBox(height: 8),
                    StudentStopCompletedCard(
                      stop: stop,
                      student: currentStudent,
                      studentStatus: studentStatus,
                      transportation: transportation,
                    ),
                  ],

                  // If student's stop but NOT arrived yet: upcoming indicator
                  if (isStudentStop && !isArrived) ...[
                    const SizedBox(height: 6),
                    _buildStudentUpcomingIndicator(),
                  ],

                  // Other students at this stop
                  _buildOtherStudentsAtStop(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Station Node ───────────────────────────────────────────────────
  Widget _buildStationNode() {
    if (isCurrentBusLocation) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: _navyLight,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: _navyLight.withAlpha(120),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(color: Colors.white, width: 2.5),
        ),
        child: const Center(
          child: Icon(
            Icons.directions_bus_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      );
    }

    if (isArrived) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: _emeraldSuccess,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: _emeraldSuccess.withAlpha(60),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.check, color: Colors.white, size: 14),
        ),
      );
    }

    if (isStudentStop) {
      return Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withAlpha(80),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(Icons.star_rounded, color: Colors.white, size: 15),
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _trackUpcoming, width: 2),
      ),
      child: Center(
        child: Text(
          "${stop.priority}",
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: _slateMuted,
          ),
        ),
      ),
    );
  }

  // ── Station Card ────────────────────────────────────────────────────
  Widget _buildStationCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:
            isCurrentBusLocation
                ? const Color(0xFFEFF6FF)
                : isArrived
                ? Colors.white
                : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isCurrentBusLocation
                  ? _navyLight.withAlpha(150)
                  : isStudentStop
                  ? const Color(0xFFF59E0B).withAlpha(120)
                  : isArrived
                  ? _emeraldSuccess.withAlpha(60)
                  : const Color(0xFFE2E8F0),
          width: isCurrentBusLocation || isStudentStop ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isCurrentBusLocation)
            BoxShadow(
              color: _navyLight.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          else
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Stop ${stop.priority}",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            isCurrentBusLocation
                                ? _navyLight
                                : isArrived
                                ? _emeraldDark
                                : _slateMuted,
                      ),
                    ),
                    if (isStudentStop) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: const Text(
                          "Your Child's Stop",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  stop.stopName ?? "Unnamed Stop",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isArrived ? _slateText : const Color(0xFF475569),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (isCurrentBusLocation) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _navyLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.near_me_rounded, color: Colors.white, size: 11),
            SizedBox(width: 4),
            Text(
              "Vehicle is here",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (isArrived) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _emeraldBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _emeraldSuccess.withAlpha(80)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: _emeraldDark, size: 11),
            SizedBox(width: 4),
            Text(
              "Arrived",
              style: TextStyle(
                color: _emeraldDark,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Text(
        "Upcoming",
        style: TextStyle(
          color: _slateMuted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStudentUpcomingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_filled_rounded,
            size: 13,
            color: Color(0xFFD97706),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              "Bus is heading towards ${currentStudent?.fullName ?? 'child'}'s stop",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF92400E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherStudentsAtStop() {
    final progress = transportation.getProgressForStop(stop.id);
    if (progress == null || progress.studentsStopStatuses.isEmpty) {
      return const SizedBox.shrink();
    }

    final otherStatuses =
        progress.studentsStopStatuses
            .where((s) => s.studentId != currentStudent?.id)
            .toList();

    if (otherStatuses.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children:
            otherStatuses.map((s) {
              final isPicked = s.isPicked;
              final isDropped = s.isDropped;
              final statusColor =
                  (isPicked || isDropped)
                      ? _emeraldSuccess
                      : const Color(0xFFEF4444);

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (isPicked || isDropped)
                          ? Icons.check_circle_rounded
                          : Icons.remove_circle_outline_rounded,
                      size: 10,
                      color: statusColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Student #${s.studentId}: ${s.status ?? 'arrived'}",
                      style: const TextStyle(
                        fontSize: 10,
                        color: _slateMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}
