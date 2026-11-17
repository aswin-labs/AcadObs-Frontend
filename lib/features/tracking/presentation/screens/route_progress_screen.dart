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

  /// When `null`, defaults to Today.
  DateTime? _selectedDate;

  /// Defaults to `'PICKUP'` when no filter is changed.
  String _selectedRouteType = 'PICKUP';

  static const _navyPrimary = Color(0xFF1E3A8A);
  static const _navyLight = Color(0xFF2563EB);
  static const _emeraldSuccess = Color(0xFF10B981);
  static const _slateText = Color(0xFF0F172A);
  static const _slateMuted = Color(0xFF64748B);

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get _isTodaySelected {
    if (_selectedDate == null) return true;
    return _isSameDay(_selectedDate!, DateTime.now());
  }

  bool get _isDefaultFilter =>
      _isTodaySelected && _selectedRouteType.toUpperCase() == 'PICKUP';

  DateTime get _effectiveDate => _selectedDate ?? DateTime.now();

  String get _apiDateParam => DateFormat('yyyy-MM-dd').format(_effectiveDate);

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
        routeType: _selectedRouteType,
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
            routeType: _selectedRouteType,
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

  void _applyRouteType(String routeType) {
    final normalized = routeType.toUpperCase();
    if (_selectedRouteType == normalized) return;
    setState(() {
      _selectedRouteType = normalized;
    });
    refreshData();
  }

  void _resetFiltersToDefault() {
    setState(() {
      _selectedDate = null;
      _selectedRouteType = 'PICKUP';
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
    return Consumer<StudentRouteProvider>(
      builder: (context, provider, _) {
        final transportation = provider.todayTransportation;
        final isRouteCurrentlyActive =
            _isTodaySelected &&
            transportation != null &&
            (transportation.route?.active == true);

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
          body: Column(
            children: [
              // Subtle top progress bar when refresh/loading is active
              if (provider.isTransportationLoading)
                const LinearProgressIndicator(
                  minHeight: 3,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(_navyLight),
                ),

              // Date & Route Type (PICKUP / DROP) Filter Bar
              _buildFilterBar(provider.isTransportationLoading),

              // Main Content Area
              Expanded(child: _buildBodyContent(provider)),
            ],
          ),
          bottomNavigationBar:
              isRouteCurrentlyActive
                  ? _buildNearestLocationBottomBar(
                    transportation: transportation,
                    isRefreshing: provider.isTransportationLoading,
                  )
                  : null,
          floatingActionButton:
              isRouteCurrentlyActive
                  ? null
                  : FloatingActionButton(
                    backgroundColor: Colors.black,
                    shape: const CircleBorder(),
                    elevation: 4,
                    onPressed:
                        provider.isTransportationLoading ? null : refreshData,
                    tooltip:
                        provider.isTransportationLoading
                            ? "Refreshing..."
                            : "Refresh Route",
                    child:
                        provider.isTransportationLoading
                            ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                  ),
        );
      },
    );
  }

  Widget _buildFilterBar(bool isLoading) {
    final isToday = _isTodaySelected;
    final formattedDate = DateFormat('EEE, dd MMM yyyy').format(_effectiveDate);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              _isDefaultFilter
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Date Filter
          Row(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
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
                            formattedDate,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _slateText,
                            ),
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "Today",
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Reset button when viewing a non-default date or routeType
              if (!_isDefaultFilter) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: isLoading ? null : _resetFiltersToDefault,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close_rounded,
                          size: 13,
                          color: Color(0xFFDC2626),
                        ),
                        SizedBox(width: 3),
                        Text(
                          "Reset",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                      ],
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

          const SizedBox(height: 8),

          // Bottom Row: Route Type Toggle (PICKUP / DROP)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildRouteTypeSegment(
                    type: 'PICKUP',
                    label: 'Pickup Route',
                    icon: Icons.wb_sunny_outlined,
                    isLoading: isLoading,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildRouteTypeSegment(
                    type: 'DROP',
                    label: 'Drop Route',
                    icon: Icons.home_outlined,
                    isLoading: isLoading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteTypeSegment({
    required String type,
    required String label,
    required IconData icon,
    required bool isLoading,
  }) {
    final isSelected = _selectedRouteType == type;
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: isLoading ? null : () => _applyRouteType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? _navyPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: _navyPrimary.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : _slateMuted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : _slateMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearestLocationBottomBar({
    required TodayTransportationModel transportation,
    required bool isRefreshing,
  }) {
    final nearest = transportation.nearestStop;
    final lastLoc = transportation.lastLocation;

    // Fallback stop name if nearestStop is null
    String locationTitle = nearest?.stopName ?? '';
    if (locationTitle.trim().isEmpty) {
      final sortedStops = transportation.sortedStops;
      for (final stop in sortedStops) {
        if (transportation.isStopArrived(stop.id)) {
          locationTitle = stop.stopName ?? '';
        }
      }
    }
    if (locationTitle.trim().isEmpty) {
      locationTitle =
          transportation.route?.routeName ?? 'Route Currently Active';
    }

    final distanceLabel =
        (nearest?.distance != null && nearest!.distance!.trim().isNotEmpty)
            ? nearest.distance!.trim()
            : (nearest?.distanceMeters != null
                ? '${nearest!.distanceMeters} m'
                : null);

    String? subtitleText;
    final parts = <String>[];
    if (nearest?.priority != null) {
      parts.add('Stop #${nearest!.priority}');
    }
    if (lastLoc?.createdAt != null) {
      parts.add(
        'Updated ${DateFormat('hh:mm a').format(lastLoc!.createdAt!.toLocal())}',
      );
    }
    if (parts.isNotEmpty) {
      subtitleText = parts.join(' • ');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Location Pulse Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _emeraldSuccess.withValues(alpha: 0.35),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.near_me_rounded,
                    color: _emeraldSuccess,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Nearest Location Details
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: _emeraldSuccess,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'NEAREST LOCATION',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ],
                        ),
                        if (distanceLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFBFDBFE),
                              ),
                            ),
                            child: Text(
                              '$distanceLabel away',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _navyPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      locationTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: _slateText,
                      ),
                    ),
                    if (subtitleText != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: _slateMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Refresh Button inside the Bottom White Bar
              ElevatedButton.icon(
                onPressed: isRefreshing ? null : refreshData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navyPrimary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: _navyPrimary.withValues(alpha: 0.6),
                  disabledForegroundColor: Colors.white,
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon:
                    isRefreshing
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.refresh_rounded, size: 18),
                label: Text(
                  isRefreshing ? 'Syncing' : 'Refresh',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent(StudentRouteProvider provider) {
    if (provider.isTransportationLoading &&
        provider.todayTransportation == null) {
      return const Center(child: CircularProgressIndicator(color: _navyLight));
    }

    if (provider.isRouteInactive && provider.todayTransportation == null) {
      return _buildInactiveRouteState(provider.transportationError);
    }

    if (provider.transportationError != null &&
        provider.todayTransportation == null) {
      return _buildErrorState(provider.transportationError!);
    }

    final transportation = provider.todayTransportation;
    if (transportation == null || transportation.stops.isEmpty) {
      return _buildInactiveRouteState(null);
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
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 36),
        children: [
          // Top Route Summary Card
          RouteTopCard(
            transportation: transportation,
            latestArrivedStop: latestArrivedStop,
            selectedDate: _effectiveDate,
            isToday: _isTodaySelected,
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
        Expanded(
          child: Row(
            children: [
              const Icon(LucideIcons.route, size: 18, color: _navyPrimary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  "Route Stops Timeline ($stopCount)",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: _slateText,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
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

  String _resolveFriendlyInactiveMessage(String? rawMessage) {
    final formattedDate = DateFormat('EEEE, dd MMM yyyy').format(_effectiveDate);
    final routeLabel = _selectedRouteType == 'DROP' ? 'Drop' : 'Pickup';
    if (!_isTodaySelected) {
      if (rawMessage == null ||
          rawMessage.trim().isEmpty ||
          rawMessage.toLowerCase().contains('today') ||
          rawMessage.toLowerCase().contains('right now')) {
        return "No $routeLabel bus trip or stop activity was recorded for $formattedDate. You can switch between Pickup/Drop or pick another date above.";
      }
      return rawMessage;
    }

    if (rawMessage != null && rawMessage.trim().isNotEmpty) {
      return rawMessage;
    }
    return "The $routeLabel route has not started for today yet, or the route is currently offline.";
  }

  Widget _buildInactiveRouteState(String? rawMessage) {
    final formattedShortDate = DateFormat('dd MMM yyyy').format(_effectiveDate);
    final friendlyMessage = _resolveFriendlyInactiveMessage(rawMessage);
    final routeLabel = _selectedRouteType == 'DROP' ? 'Drop' : 'Pickup';

    return RefreshIndicator(
      onRefresh: refreshData,
      color: _navyLight,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFC7D2FE),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _isTodaySelected
                          ? LucideIcons.bus
                          : LucideIcons.calendarX2,
                      color: _navyPrimary,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _isTodaySelected
                        ? "$routeLabel Route Not Active Right Now"
                        : "No $routeLabel Activity on $formattedShortDate",
                    style: const TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: _slateText,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    friendlyMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: _slateMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (!_isDefaultFilter)
                        OutlinedButton.icon(
                          onPressed: _resetFiltersToDefault,
                          icon: const Icon(LucideIcons.calendarCheck, size: 16),
                          label: const Text(
                            "Reset Filters",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _navyPrimary,
                            minimumSize: const Size(0, 44),
                            side: const BorderSide(color: _navyPrimary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: refreshData,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          _isTodaySelected ? "Check Again" : "Retry",
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navyPrimary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 11,
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
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    final lower = message.toLowerCase();
    final isNetworkIssue =
        lower.contains('network') ||
        lower.contains('connect') ||
        lower.contains('internet') ||
        lower.contains('timeout');

    return RefreshIndicator(
      onRefresh: refreshData,
      color: _navyLight,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color:
                          isNetworkIssue
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            isNetworkIssue
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFFFCA5A5),
                      ),
                    ),
                    child: Icon(
                      isNetworkIssue
                          ? LucideIcons.wifiOff
                          : Icons.error_outline_rounded,
                      color:
                          isNetworkIssue
                              ? const Color(0xFFD97706)
                              : const Color(0xFFDC2626),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isNetworkIssue
                        ? "Connection Issue"
                        : "Unable to Load Route",
                    style: const TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: _slateText,
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
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (!_isDefaultFilter)
                        OutlinedButton.icon(
                          onPressed: _resetFiltersToDefault,
                          icon: const Icon(LucideIcons.calendarCheck, size: 16),
                          label: const Text(
                            "Reset Filters",
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _navyPrimary,
                            minimumSize: const Size(0, 44),
                            side: const BorderSide(color: _navyPrimary),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ElevatedButton.icon(
                        onPressed: refreshData,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(
                          "Try Again",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _navyPrimary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 11,
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
          ),
        ],
      ),
    );
  }
}
