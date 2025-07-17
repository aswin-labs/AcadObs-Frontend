// import 'package:acadobs/features/parents/data/models/notice_model.dart';
import 'package:acadobs/features/parents/data/models/notice_model.dart';
import 'package:acadobs/features/parents/presentation/notices/screens/notice_details_screen.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> parentRoutes = [
  GoRoute(
    path: '/noticedetails',
    name: RouteConstants.parentdetails,
    builder: (context, state) {
      final Notices noticedetail = state.extra as Notices;
      return NoticeDetailsScreen(notices: noticedetail);
    },
  ),
];
