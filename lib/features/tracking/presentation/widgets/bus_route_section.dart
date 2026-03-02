import 'package:acadobs/features/tracking/presentation/provider/student_route_provider.dart';
import 'package:acadobs/features/tracking/presentation/widgets/bus_route_bottomsheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      context.read<StudentRouteProvider>().getRouteCount();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          SizedBox(height: 16),

          // Consumer<ParentProvider>(
          //   builder: (context, provider, _) {
          //     if (provider.students.isEmpty) {
          //       return Container(
          //         padding: EdgeInsets.all(32),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(16),
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.black.withAlpha(12),
          //               blurRadius: 10,
          //               offset: Offset(0, 4),
          //             ),
          //           ],
          //         ),
          //         child: Center(
          //           child: Text(
          //             "No students found",
          //             style: TextStyle(color: Colors.grey[600]),
          //           ),
          //         ),
          //       );
          //     }

          //     return ListView.separated(
          //       padding: EdgeInsets.zero,
          //       shrinkWrap: true,
          //       physics: NeverScrollableScrollPhysics(),
          //       itemCount: provider.students.length,
          //       separatorBuilder: (context, index) => SizedBox(height: 12),
          //       itemBuilder: (context, index) {
          //         return ;
          //       },
          //     );
          //   },
          // ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showBusRoutesBottomsheet(context: context);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF35C2C1), Color(0xFF00AEF0)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(12),
                          child:
                          // Image.asset(
                          //   "assets/icon/bus.png",
                          //   fit: BoxFit.cover,
                          //   errorBuilder: (context, error, stackTrace) {
                          //     return
                          Icon(Icons.route, color: Colors.white, size: 24),
                          // },
                          // ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bus Routes",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Consumer<StudentRouteProvider>(
                              builder: (context, provider, _) {
                                return Text(
                                  "${provider.routeCount} Routes",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
