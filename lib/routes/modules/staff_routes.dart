import 'package:acadobs/features/teacher/data/models/attendance/attendance_model.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_upload_model.dart';
import 'package:acadobs/features/teacher/data/models/staff_duty_model.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/attendance_details_screen.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/attendance_taking_screen.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/edit_attendance_screen.dart';
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

  // Attendance
  GoRoute(
    path: '/attendanceTaking',
    name: RouteConstants.attendanceTaking,
    builder: (context, state) {
      final AttendanceUploadModel attendance =
          state.extra as AttendanceUploadModel;
      return AttendanceTakingScreen(
        attendance: attendance,
      );
    },
  ),
  GoRoute(
    path: '/attendanceDetails',
    name: RouteConstants.attendanceDetails,
    builder: (context, state) {
      final attendance = state.extra as AttendanceModel;
      return AttendanceDetailsScreen(attendance: attendance);
    },
  ),
   GoRoute(
    path: '/editAttendance',
    name: RouteConstants.editAttendance,
    builder: (context, state) {
      final attendance = state.extra as AttendanceModel;
      return EditAttendanceScreen(attendance: attendance);
    },
  ),
];
