import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/tracking/presentation/provider/student_route_provider.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RouteProgressScreen extends StatefulWidget {
  final int routeId;
  const RouteProgressScreen({super.key, required this.routeId});

  @override
  State<RouteProgressScreen> createState() => _RouteProgressScreenState();
}

class _RouteProgressScreenState extends State<RouteProgressScreen> {
  static const _gradientStart = Color(0xFF35C2C1);
  static const _gradientEnd = Color(0xFF00AEF0);
  static const _accentDone = Color(0xFF22C55E);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshData();
    });
  }

  Future<void> refreshData() async {
    await Future.wait([
      context.read<StudentRouteProvider>().getStopsForParent(
        routeId: widget.routeId,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F6FB),
      appBar: CommonAppBar(
        title: "Route In Progress",
        isBackButton: true,
        backgroundColor: _gradientStart,
        titleColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildTopCard(),
          Expanded(
            child: Consumer<StudentRouteProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: _gradientEnd),
                  );
                }
                if (provider.guardianStops.isEmpty) {
                  return Center(
                    child: emptyScreen(message: "No Stops Available"),
                  );
                }
                final stops = provider.guardianStops;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  itemCount: stops.length,
                  itemBuilder: (context, index) {
                    final stop = stops[index];
                    return _buildStopTile(
                      name: stop.stopName!,
                      status: stop.arrived!,
                      index: index,
                      priority: stop.priority!,
                      isLast: index == stops.length - 1,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: CommonFloatingButton(
        onPressed: refreshData,
        icon: Icons.refresh,
      ),
    );
  }

  // ── Top Card ─────────────────────────────────────────────────────
  Widget _buildTopCard() {
    return Consumer<StudentRouteProvider>(
      builder: (context, provider, _) {
        final total = provider.guardianStops.length;
        final arrived =
            provider.guardianStops.where((s) => s.arrived == true).length;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_gradientStart, _gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Driver Row ──
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Alex Johnson",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Live badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withAlpha(60)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Color(0xFF4ADE80), size: 7),
                        SizedBox(width: 5),
                        Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Stats Row ──
              Row(
                children: [
                  _buildStatChip(
                    icon: Icons.place_rounded,
                    label: "$arrived/$total Stops",
                  ),
                  const SizedBox(width: 10),
                  _buildStatChip(
                    icon: Icons.directions_bus_rounded,
                    label: "On Route",
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stop Tile ─────────────────────────────────────────────────────
  Widget _buildStopTile({
    required String name,
    required int priority,
    required bool status,
    required int index,
    required bool isLast,
  }) {
    final isDone = status;
    final isCurrent =
        !status &&
        index ==
            context.read<StudentRouteProvider>().guardianStops.indexWhere(
              (s) => s.arrived == false,
            );

    // Timeline dot color
    final dotColor =
        isDone
            ? _accentDone
            : isCurrent
            ? _gradientEnd
            : const Color(0xFFCBD5E1);

    // Timeline line color
    final lineColor =
        isDone ? _accentDone.withAlpha(120) : const Color(0xFFE2E8F0);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Timeline ──
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 16,
                  color: index == 0 ? Colors.transparent : lineColor,
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border:
                        (!isDone && !isCurrent)
                            ? Border.all(
                              color: const Color(0xFFCBD5E1),
                              width: 1.5,
                            )
                            : null,
                    boxShadow:
                        isCurrent
                            ? [
                              BoxShadow(
                                color: _gradientEnd.withAlpha(100),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                            : [],
                  ),
                  child:
                      isDone
                          ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 9,
                          )
                          : null,
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: lineColor)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // ── Card ──
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient:
                    isCurrent
                        ? const LinearGradient(
                          colors: [_gradientStart, _gradientEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                        : null,
                color:
                    isCurrent
                        ? null
                        : isDone
                        ? const Color(0xFFF0FDF4)
                        : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isCurrent
                          ? Colors.transparent
                          : isDone
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFE9EEF4),
                ),
                boxShadow:
                    isCurrent
                        ? [
                          BoxShadow(
                            color: _gradientEnd.withAlpha(60),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color:
                            isCurrent
                                ? Colors.white
                                : isDone
                                ? const Color(0xFF166534)
                                : const Color(0xFFADB5C2),
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "HERE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color:
                          isCurrent
                              ? Colors.white.withAlpha(25)
                              : isDone
                              ? _accentDone.withAlpha(30)
                              : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        "$priority",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color:
                              isCurrent
                                  ? Colors.white
                                  : isDone
                                  ? _accentDone
                                  : const Color(0xFFADB5C2),
                        ),
                      ),
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
