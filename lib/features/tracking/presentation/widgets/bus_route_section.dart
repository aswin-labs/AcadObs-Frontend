import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/features/tracking/data/models/student_route_model.dart';
import 'package:acadobs/features/tracking/presentation/provider/student_route_provider.dart';
import 'package:acadobs/features/tracking/presentation/widgets/bus_route_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BusRouteSection extends StatefulWidget {
  const BusRouteSection({super.key});

  @override
  State<BusRouteSection> createState() => _BusRouteSectionState();
}

class _BusRouteSectionState extends State<BusRouteSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentRouteProvider>().getStudentRoutes();
    });
  }

  /// Groups raw student-route entries by route ID.
  /// Students sharing the same route appear on one card.
  List<_GroupedRoute> _group(List<StudentRouteModel> raw) {
    final Map<int, _GroupedRoute> map = {};
    for (final s in raw) {
      final route = s.routes;
      if (route == null) continue;
      final rid = route.id ?? -1;
      if (map.containsKey(rid)) {
        if (s.fullName != null && s.fullName!.isNotEmpty) {
          map[rid]!.studentNames.add(s.fullName!);
        }
        if (s.id != null) {
          map[rid]!.studentIds.add(s.id!);
        }
      } else {
        map[rid] = _GroupedRoute(
          routeId: rid,
          routeName: route.routeName ?? '',
          vehicleType: route.vehicle?.type ?? '',
          vehicleNumber: route.vehicle?.vehicleNumber ?? '',
          driverName: route.driver?.name ?? '',
          vehiclePhoto: route.vehicle?.photo,
          studentNames: [
            if (s.fullName != null && s.fullName!.isNotEmpty) s.fullName!,
          ],
          studentIds: [
            if (s.id != null) s.id!,
          ],
        );
      }
    }
    return map.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- Section header ------------------------------------------
          Row(
            children: const [
              Icon(Icons.directions_bus, color: Color(0xFF00AEF0), size: 28),
              SizedBox(width: 8),
              Text(
                "Transport",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // -- Cards ----------------------------------------------------
          Consumer<StudentRouteProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CommonShimmerTile(height: 70),
                );
              }

              final grouped = _group(provider.studentRoutes);

              if (grouped.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text("No routes found")),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: grouped.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final g = grouped[index];
                  return BusRouteCard(
                    routeName: g.routeName,
                    vehicleType: g.vehicleType,
                    vehicleNumber: g.vehicleNumber,
                    driverName: g.driverName,
                    vehiclePhoto: g.vehiclePhoto,
                    studentNames: g.studentNames,
                    onTap:
                        () => context.pushNamed(
                          RouteConstants.routeProgress,
                          extra: {
                            'routeId': g.routeId,
                            'studentId':
                                g.studentIds.isNotEmpty
                                    ? g.studentIds.first
                                    : null,
                          },
                        ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- Internal grouping DTO ----------------------------------------------------

class _GroupedRoute {
  final int routeId;
  final String routeName;
  final String vehicleType;
  final String vehicleNumber;
  final String driverName;
  final String? vehiclePhoto;
  final List<String> studentNames;
  final List<int> studentIds;

  _GroupedRoute({
    required this.routeId,
    required this.routeName,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.driverName,
    required this.vehiclePhoto,
    required this.studentNames,
    this.studentIds = const [],
  });
}
