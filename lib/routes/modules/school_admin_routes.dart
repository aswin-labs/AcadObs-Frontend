import 'package:acadobs/features/admin/presentation/student/screens/students_home_screen.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> schoolAdminRoutes = [
  // ***************Students********************
  GoRoute(
    path: '/studentsHome',
    name: RouteConstants.studentsHome,
    builder: (context, state) => StudentsHomeScreen(),
  ),
 
  ];