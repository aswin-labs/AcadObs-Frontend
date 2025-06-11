import 'package:acadobs/routes/modules/superadmin_routes.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [...superadminRoutes],
);
