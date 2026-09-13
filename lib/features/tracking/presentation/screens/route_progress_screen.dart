import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/tracking/data/models/today_transportation_model.dart';
import 'package:acadobs/features/tracking/presentation/provider/student_route_provider.dart';
import 'package:acadobs/features/tracking/presentation/widgets/route_timeline_tile.dart';
import 'package:acadobs/features/tracking/presentation/widgets/route_top_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';

class RouteProgressScreen extends StatefulWidget {
  final int? routeId;
  final int? studentId;

  const RouteProgressScreen({super.key, this.routeId, this.studentId});

  @override
  State<RouteProgressScreen> createState() => _RouteProgressScreenState();
}

class _RouteProgressScreenState extends State<RouteProgressScreen> {
  int? _activeStudentId;

  static const _navyPrimary = Color(0xFF1E3A8A);
  static const _navyLight = Color(0xFF2563EB);
  static const _slateText = Color(0xFF0F172A);
  static const _slateMuted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    _activeStudentId = widget.studentId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAndFetch();
    });
  }

  Future<void> _initAndFetch() async {
    final provider = context.read<StudentRouteProvider>();

    if (_activeStudentId == null) {
      if (provider.studentRoutes.isEmpty) {
        await provider.getStudentRoutes();
      }

      if (widget.routeId != null) {
        final match = provider.studentRoutes.where(
          (s) => s.routes?.id == widget.routeId,
        );
        if (match.isNotEmpty) {
          _activeStudentId = match.first.id;
        }
      }

      if (_activeStudentId == null && provider.studentRoutes.isNotEmpty) {
        _activeStudentId = provider.studentRoutes.first.id;
      }
    }

    if (_activeStudentId != null) {
      await provider.getTodayTransportationByStudentId(
        studentId: _activeStudentId!,
      );
    }
  }

  Future<void> refreshData() async {
    if (_activeStudentId != null) {
      await context
          .read<StudentRouteProvider>()
          .getTodayTransportationByStudentId(studentId: _activeStudentId!);
    } else {
      await _initAndFetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonAppBar(
        title: "Live Route Tracker",
        isBackButton: true,
        backgroundColor: _navyPrimary,
        titleColor: Colors.white,
      ),
      body: Consumer<StudentRouteProvider>(
        builder: (context, provider, _) {
          if (provider.isTransportationLoading &&
              provider.todayTransportation == null) {
            return const Center(
              child: CircularProgressIndicator(color: _navyLight),
            );
          }

          if (provider.isRouteInactive &&
              provider.todayTransportation == null) {
            return _buildInactiveRouteState(
              provider.transportationError ??
                  "The transportation route is not active right now.",
            );
          }

          if (provider.transportationError != null &&
              provider.todayTransportation == null) {
            return _buildErrorState(provider.transportationError!);
          }

          final transportation = provider.todayTransportation;
          if (transportation == null || transportation.stops.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  emptyScreen(message: "No route information available today"),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: refreshData,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Retry"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navyPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final sortedStops = transportation.sortedStops;
          final currentStudent = transportation.student;

          // Latest arrived stop (current vehicle position)
          TransportationStop? latestArrivedStop;
          for (final stop in sortedStops) {
            if (transportation.isStopArrived(stop.id)) {
              latestArrivedStop = stop;
            }
          }

          return Column(
            children: [
              // Subtle top progress bar when background refresh is active
              if (provider.isTransportationLoading)
                const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(_navyLight),
                ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: refreshData,
                  color: _navyLight,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    children: [
                      // Top Route Summary Card
                      RouteTopCard(
                        transportation: transportation,
                        latestArrivedStop: latestArrivedStop,
                      ),
                      const SizedBox(height: 24),

                      // Timeline Section Header
                      _buildTimelineHeader(sortedStops.length),
                      const SizedBox(height: 12),

                      // "Where Is My Train" Style Continuous Track
                      _buildTimeline(
                        sortedStops: sortedStops,
                        transportation: transportation,
                        currentStudent: currentStudent,
                        latestArrivedStop: latestArrivedStop,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<StudentRouteProvider>(
        builder: (context, provider, _) {
          final isRefreshing = provider.isTransportationLoading;
          return FloatingActionButton(
            backgroundColor: Colors.black,
            shape: const CircleBorder(),
            elevation: 4,
            onPressed: isRefreshing ? null : refreshData,
            tooltip: isRefreshing ? "Refreshing..." : "Refresh Route",
            child:
                isRefreshing
                    ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineHeader(int stopCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(LucideIcons.route, size: 18, color: _navyPrimary),
            const SizedBox(width: 8),
            Text(
              "Route Stops Timeline ($stopCount)",
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: _slateText,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            "Priority Order",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _slateMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline({
    required List<TransportationStop> sortedStops,
    required TodayTransportationModel transportation,
    required StudentTransportationInfo? currentStudent,
    required TransportationStop? latestArrivedStop,
  }) {
    return Column(
      children: List.generate(sortedStops.length, (index) {
        final stop = sortedStops[index];
        final isArrived = transportation.isStopArrived(stop.id);
        final isStudentStop = (currentStudent?.stopId == stop.id);
        final isCurrentBusLocation = (latestArrivedStop?.id == stop.id);
        final isFirst = (index == 0);
        final isLast = (index == sortedStops.length - 1);

        final prevArrived =
            index > 0 &&
            transportation.isStopArrived(sortedStops[index - 1].id);
        final nextArrived =
            !isLast && transportation.isStopArrived(sortedStops[index + 1].id);

        return RouteTimelineTile(
          stop: stop,
          index: index,
          isArrived: isArrived,
          isStudentStop: isStudentStop,
          isCurrentBusLocation: isCurrentBusLocation,
          isFirst: isFirst,
          isLast: isLast,
          prevArrived: prevArrived,
          nextArrived: nextArrived,
          transportation: transportation,
          currentStudent: currentStudent,
        );
      }),
    );
  }

  Widget _buildInactiveRouteState(String message) {
    return RefreshIndicator(
      onRefresh: refreshData,
      color: _navyLight,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFC7D2FE),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withAlpha(20),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.bus,
                    color: _navyPrimary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Route is Not Active Right Now",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _slateText,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: _slateMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: refreshData,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text(
                    "Check Again",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navyPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return RefreshIndicator(
      onRefresh: refreshData,
      color: _navyLight,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFFDC2626),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Unable to Load Route",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _slateText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: _slateMuted),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: refreshData,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text("Retry"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navyPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
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
