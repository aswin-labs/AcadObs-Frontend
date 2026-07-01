import 'package:acadobs/routes/modules/common_routes.dart';
import 'package:acadobs/routes/modules/parent_route.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ...commonRoutes,
    ...staffRoutes,
    ...parentRoutes,
  ],
);
