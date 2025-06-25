import 'package:acadobs/features/teacher/data/models/staff_duty_model.dart';
import 'package:acadobs/features/teacher/presentation/duties/screens/duty_detail_screen.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> staffRoutes = [
  // Duties
  GoRoute(
    path: '/dutyDetail',
    name: RouteConstants.dutyDetail,
    builder: (context, state) {
      final StaffDuty staffDuty = state.extra as StaffDuty;
      return DutyDetailScreen(staffDuty: staffDuty);
    },
  ),
];
