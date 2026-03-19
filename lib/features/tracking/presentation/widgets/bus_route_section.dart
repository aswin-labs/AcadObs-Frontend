import 'package:acadobs/core/utils/common_shimmer_tile.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_bus, color: Color(0xFF00AEF0), size: 28),
              SizedBox(width: 8),
              Text(
                "Bus Tracking",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          // SizedBox(height: 16),
          Consumer<StudentRouteProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CommonShimmerTile(height: 70),
                );
              }

              final studentRoutes = provider.studentRoutes;
              if (studentRoutes.isEmpty ||
                  (studentRoutes[0].routes?.isEmpty ?? true)) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text("No routes found")),
                );
              }

              final routes = studentRoutes[0].routes!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  final studentroute = routes[index];
                  return BusRouteCard(
                    routeName: studentroute.routeName ?? "",
                    type: studentroute.type ?? "",
                    isLive: true,
                    onTap:
                        () => context.pushNamed(
                          RouteConstants.routeProgress,
                          extra: studentroute.id ?? 0,
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
