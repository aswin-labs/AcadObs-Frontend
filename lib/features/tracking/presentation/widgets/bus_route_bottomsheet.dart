import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/tracking/presentation/provider/student_route_provider.dart';
import 'package:acadobs/features/tracking/presentation/widgets/bus_route_card.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void showBusRoutesBottomsheet({required BuildContext context}) {
  context.read<StudentRouteProvider>().getStudentRoutes();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: Responsive.height * 1.5),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back),
                  ),
                  Spacer(),
                  Text(
                    "All Bus Routes",
                    style: context.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: Responsive.height * 3),
              Consumer<StudentRouteProvider>(
                builder: (context, provider, _) {
                  // if (provider.isLoading) {
                  //   return const Padding(
                  //     padding: EdgeInsets.symmetric(vertical: 32),
                  //     child: Center(child: CommonShimmerTile(height: 100)),
                  //   );
                  // }
                  // final routes = provider.studentRoutes;
                  // if (routes.isEmpty) {
                  //   return Padding(
                  //     padding: EdgeInsets.symmetric(vertical: 32),
                  //     child: Center(
                  //       child: emptyScreen(message: "No routes found"),
                  //     ),
                  //   );
                  // }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.studentRoutes[0].routes!.length,
                    itemBuilder: (context, index) {
                      final studentroute =
                          provider.studentRoutes[0].routes![index];
                      return BusRouteCard(
                        // studentName:
                        //     "studentroute.fullName ?? "
                        //     "",
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
              SizedBox(height: Responsive.height * 1),
            ],
          ),
        ),
      );
    },
  );
}
