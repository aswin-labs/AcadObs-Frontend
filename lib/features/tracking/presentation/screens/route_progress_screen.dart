import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/tracking/data/models/today_transportation_model.dart';
import 'package:acadobs/features/tracking/presentation/provider/student_route_provider.dart';
import 'package:acadobs/features/tracking/presentation/widgets/route_timeline_tile.dart';
import 'package:acadobs/features/tracking/presentation/widgets/route_top_card.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  /// When `null`, defaults to Today (no `date` query param sent, matching default backend behavior).
  DateTime? _selectedDate;

  static const _navyPrimary = Color(0xFF1E3A8A);
  static const _navyLight = Color(0xFF2563EB);
  static const _slateText = Color(0xFF0F172A);
  static const _slateMuted = Color(0xFF64748B);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get _isTodaySelected {
    if (_selectedDate == null) return true;
    return _isSameDay(_selectedDate!, DateTime.now());
  }

  DateTime get _effectiveDate => _selectedDate ?? DateTime.now();

  String? get _apiDateParam {
    if (_isTodaySelected) return null;
    return DateFormat('yyyy-MM-dd').format(_selectedDate!);
  }

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
        date: _apiDateParam,
      );
    }
  }

  Future<void> refreshData() async {
    if (_activeStudentId != null) {
      await context
          .read<StudentRouteProvider>()
          .getTodayTransportationByStudentId(
            studentId: _activeStudentId!,
            date: _apiDateParam,
          );
    } else {
      await _initAndFetch();
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initial = _effectiveDate.isAfter(today) ? today : _effectiveDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2023, 1, 1),
      lastDate: today,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _navyPrimary,
              onPrimary: Colors.white,
              onSurface: _slateText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _applySelectedDate(picked);
    }
  }

  void _applySelectedDate(DateTime? date) {
    final now = DateTime.now();
    setState(() {
      if (date == null || _isSameDay(date, now)) {
        _selectedDate = null;
      } else {
        _selectedDate = DateTime(date.year, date.month, date.day);
      }
    });
    refreshData();
  }

  void _stepDate(int daysDelta) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = DateTime(
      _effectiveDate.year,
      _effectiveDate.month,
      _effectiveDate.day,
    );
    final target = current.add(Duration(days: daysDelta));
    if (target.isAfter(today)) return;
    _applySelectedDate(target);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonAppBar(
        title: "Live Route Tracker",
        isBackButton: true,
        backgroundColor: _navyPrimary,
        titleColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _pickDate,
            tooltip: "Filter by Date",
            icon: const Icon(
              LucideIcons.calendar,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
      body: Consumer<StudentRouteProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Subtle top progress bar when refresh/loading is active
              if (provider.isTransportationLoading)
                const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(_navyLight),
                ),

              // Date Filter Bar (Always visible so user can switch dates anytime)
              _buildDateFilterBar(provider.isTransportationLoading),

              // Main Content Area
              Expanded(child: _buildBodyContent(provider)),
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

  Widget _buildDateFilterBar(bool isLoading) {
    final isToday = _isTodaySelected;
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(_effectiveDate);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color:
              isToday
                  ? const Color(0xFFE2E8F0)
                  : _navyLight.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Day Button
          IconButton(
            onPressed: isLoading ? null : () => _stepDate(-1),
            tooltip: "Previous Day",
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              LucideIcons.chevronLeft,
              size: 18,
              color: _slateText,
            ),
          ),

          // Center Date Picker Trigger
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: isLoading ? null : _pickDate,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color:
                            isToday
                                ? const Color(0xFFEEF2FF)
                                : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        LucideIcons.calendar,
                        size: 15,
                        color: _navyPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isToday ? "Today • $formattedDate" : formattedDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _slateText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Reset to "Today" chip when viewing a past date
          if (!isToday) ...[
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isLoading ? null : () => _applySelectedDate(null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _navyPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Today",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _navyPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 2),
          ],

          // Next Day Button (disabled when already on Today)
          IconButton(
            onPressed: (isLoading || isToday) ? null : () => _stepDate(1),
            tooltip: "Next Day",
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              LucideIcons.chevronRight,
              size: 18,
              color: isToday ? const Color(0xFFCBD5E1) : _slateText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(StudentRouteProvider provider) {
    if (provider.isTransportationLoading &&
        provider.todayTransportation == null) {
      return const Center(child: CircularProgressIndicator(color: _navyLight));
    }

    if (provider.isRouteInactive && provider.todayTransportation == null) {
      return _buildInactiveRouteState(
        provider.transportationError ??
            (_isTodaySelected
                ? "The transportation route is not active right now."
                : "No transportation activity recorded for ${DateFormat('dd MMM yyyy').format(_effectiveDate)}."),
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
            emptyScreen(
              message:
                  _isTodaySelected
                      ? "No route information available today"
                      : "No route information available for ${DateFormat('dd MMM yyyy').format(_effectiveDate)}",
            ),
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

    return RefreshIndicator(
      onRefresh: refreshData,
      color: _navyLight,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
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
                Text(
                  _isTodaySelected
                      ? "Route is Not Active Right Now"
                      : "No Route Activity on ${DateFormat('dd MMM yyyy').format(_effectiveDate)}",
                  style: const TextStyle(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isTodaySelected) ...[
                      OutlinedButton.icon(
                        onPressed: () => _applySelectedDate(null),
                        icon: const Icon(LucideIcons.calendar, size: 16),
                        label: const Text(
                          "Back to Today",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _navyPrimary,
                          side: const BorderSide(color: _navyPrimary),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
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
