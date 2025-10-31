import 'package:acadobs/routes/modules/common_routes.dart';
import 'package:acadobs/routes/modules/parent_route.dart';
import 'package:acadobs/routes/modules/school_admin_routes.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/modules/super_admin_routes.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ...commonRoutes,
    ...superAdminRoutes,
    ...schoolAdminRoutes,
    ...staffRoutes,
    ...parentRoutes,
  ],
);
