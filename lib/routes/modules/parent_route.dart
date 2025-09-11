import 'package:acadobs/features/authentication/presentation/screens/school_selection_screen.dart';
import 'package:acadobs/features/chats/presentation/widgets/share_bottom_sheet.dart';
import 'package:acadobs/features/parents/data/services/student_leave_request_details_screen.dart';
import 'package:acadobs/features/authentication/presentation/screens/profile_screen.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
// import 'package:acadobs/features/teacher/presentation/homework/screens/homework_ranking_screen.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/user_model.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> parentRoutes = [
  GoRoute(
    path: '/profilescreen',
    name: RouteConstants.profileScreen,
    builder: (context, state) {
      final UserModel usermodel = state.extra as UserModel;
      return ProfileScreen(usermodel: usermodel);
    },
  ),

  GoRoute(
    path: '/studentleaveletterscreen',
    name: RouteConstants.studentLeaveLetterScreen,
    builder: (context, state) {
      final LeaveModel leave = state.extra as LeaveModel;
      return StudentLeaveRequestDetailsScreen(leave: leave);
    },
  ),

  GoRoute(
    path: '/schoolSelectionScreen',
    name: RouteConstants.schoolSelectionScreen,
    builder: (context, state) {
      return SchoolSelectionScreen();
    },
  ),


   GoRoute(
    path: '/sharebottomsheet',
    name: RouteConstants.shareBottomSheet,
    builder: (context, state) {
      return ShareBottomSheet();
    },
  ),
];
