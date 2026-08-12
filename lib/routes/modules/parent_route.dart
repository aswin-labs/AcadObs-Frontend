import 'package:acadobs/features/authentication/presentation/screens/school_selection_screen.dart';
import 'package:acadobs/features/chats/presentation/widgets/share_bottom_sheet.dart';
import 'package:acadobs/features/parents/data/models/invoice_student_model.dart';
import 'package:acadobs/features/parents/presentation/screens/invoice_detail_screen.dart';
import 'package:acadobs/features/parents/presentation/screens/payment_screen.dart';
import 'package:acadobs/features/students/presentation/screens/prediction.dart';
import 'package:acadobs/features/students/presentation/screens/student_leave_request_details_screen.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:acadobs/features/tracking/presentation/screens/route_progress_screen.dart';
import 'package:acadobs/routes/route_extra_guard.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> parentRoutes = [
  GoRoute(
    path: '/studentleaveletterscreen',
    name: RouteConstants.studentLeaveLetterScreen,
    builder: (context, state) {
      if (state.extra == null) return buildRouteExtraFallback(context);
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

  //ai prediction
  GoRoute(
    path: '/prediction',
    name: RouteConstants.prediction,
    builder: (context, state) {
      return Prediction();
    },
  ),
  GoRoute(
    path: '/routeProgress',
    name: RouteConstants.routeProgress,
    pageBuilder: (context, state) {
      final int? routeId =
          state.extra as int? ??
          int.tryParse(state.uri.queryParameters['routeId'] ?? '');
      if (routeId == null) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: buildRouteExtraFallback(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      }
      return CustomTransitionPage(
        key: state.pageKey,
        child: RouteProgressScreen(routeId: routeId),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
    },
  ),

  // payments screen
  GoRoute(
    path: '/paymentsScreen',
    name: RouteConstants.paymentsScreen,
    builder: (context, state) {
      final int? studentId =
          state.extra as int? ??
          int.tryParse(state.uri.queryParameters['studentId'] ?? '');
      if (studentId == null) return buildRouteExtraFallback(context);
      return PaymentScreen(studentId: studentId);
    },
  ),
  //invoice detail screen
  GoRoute(
    path: '/invoiceDetailScreen',
    name: RouteConstants.invoiceDetailScreen,
    builder: (context, state) {
      if (state.extra == null) return buildRouteExtraFallback(context);
      final invoice = state.extra as InvoiceStudent;
      return InvoiceDetailScreen(invoice: invoice);
    },
  ),
];
