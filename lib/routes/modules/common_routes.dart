import 'package:acadobs/features/ai_insights/presentation/screens/ai_insights_homescreen.dart';
import 'package:acadobs/features/ai_insights/presentation/screens/career_insights_screen.dart';
import 'package:acadobs/features/ai_insights/presentation/screens/subject_insights_screen.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/presentation/screens/auth_checker.dart';
import 'package:acadobs/features/authentication/presentation/screens/login_screen.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/chats/presentation/screens/chat_screen.dart';
import 'package:acadobs/features/homeworks/data/models/homework_viewer_type.dart';
import 'package:acadobs/features/homeworks/presentation/screens/homework_details_screen.dart';
import 'package:acadobs/features/homeworks/presentation/screens/homeworks_listing_screen.dart';
import 'package:acadobs/features/profile/presentation/screens/change_password_screen.dart';
import 'package:acadobs/features/profile/presentation/screens/edit_credential.dart';
import 'package:acadobs/features/profile/presentation/screens/profile_details_screen.dart';
import 'package:acadobs/features/profile/presentation/screens/profile_screen.dart';
import 'package:acadobs/features/profile/presentation/widgets/update_profile_photo_screen.dart';
import 'package:acadobs/features/timetables/data/models/timetable_type.dart';
import 'package:acadobs/features/timetables/presentation/provider/timetables_provider.dart';
import 'package:acadobs/features/timetables/presentation/screens/all_day_timetable_screen.dart';
import 'package:acadobs/features/timetables/presentation/screens/today_timetable_screen.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/bottom_nav/presentation/bottom_nav_screen.dart';
import 'package:acadobs/shared/widgets/no_internet_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final List<GoRoute> commonRoutes = [
  // auth checker
  GoRoute(
    path: '/',
    name: RouteConstants.authChecker,
    builder: (context, state) => AuthChecker(),
  ),

  // Login
  GoRoute(
    path: '/login',
    name: RouteConstants.loginScreen,
    builder: (context, state) => LoginScreen(),
  ),

  // Bottom Nav screen
  GoRoute(
    path: '/bottomNavScreen',
    name: RouteConstants.bottomNavScreen,
    builder: (context, state) {
      final UserType? userType = state.extra as UserType?;
      return BottomNavScreen(userType: userType);
    },
  ),

  // Chats
  GoRoute(
    path: '/chatScreen',
    name: RouteConstants.chatScreen,
    builder: (context, state) {
      final chat = state.extra as ChatModel;
      return ChatScreen(chatModel: chat);
    },
  ),

  // No Internet
  GoRoute(
    path: '/noInternetScreen',
    name: RouteConstants.noInternetScreen,
    builder: (context, state) {
      return NoInternetScreen();
    },
  ),

  GoRoute(
    path: '/profilescreen',
    name: RouteConstants.profileScreen,
    builder: (context, state) {
      final forStaff = state.extra as bool;
      return ProfileScreen(forStaff: forStaff);
    },
  ),

  // Profile details
  GoRoute(
    path: '/profileDetails',
    name: RouteConstants.profileDetails,
    builder: (context, state) {
      return ProfileDetailsScreen();
    },
  ),

  // Update profile photo
  GoRoute(
    path: '/updateProfilePhoto',
    name: RouteConstants.updateProfilePhoto,
    builder: (context, state) {
      final bool forStaff = state.extra as bool;
      return UpdateProfilePhotoScreen(forStaff: forStaff);
    },
  ),

  // Change password
  GoRoute(
    path: '/changePassword',
    name: RouteConstants.changePassword,
    builder: (context, state) {
      final bool forStaff = state.extra as bool;
      return ChangePasswordScreen(forStaff: forStaff);
    },
  ),

  //edit login credentials
  GoRoute(
    path: '/changelogin',
    name: RouteConstants.changelogin,
    builder: (context, state) {
      // final bool forStaff = state.extra as bool;
      return EditCredential();
    },
  ),

  // AI Insights
  GoRoute(
    path: '/aiInsightsHome',
    name: RouteConstants.aiInsightsHome,
    builder: (context, state) {
      return AiInsightsHomescreen();
    },
  ),

  // Subject Insights
  GoRoute(
    path: '/subjectInsights',
    name: RouteConstants.subjectInsights,
    builder: (context, state) {
      return SubjectInsightsScreen();
    },
  ),

  // Career Guidance
  GoRoute(
    path: '/careerGuidance',
    name: RouteConstants.careerGuidance,
    builder: (context, state) {
      return CareerInsightsScreen();
    },
  ),

  // ********************Time table screens********************************

  // Today Timetable
  GoRoute(
    path: '/todayTimetableScreen',
    name: RouteConstants.todayTimetableScreen,
    builder: (context, state) {
      final args = state.extra as TodayTimetableParameters;
      return ChangeNotifierProvider(
        create: (_) => TimetablesProvider(),
        child: TodayTimetableScreen(
          timetableType: args.timetableType,
          studentId: int.tryParse(args.studentId ?? ''),
        ),
      );
    },
  ),

  // All days Timetable
  GoRoute(
    path: '/allDayTimetableScreen',
    name: RouteConstants.allDayTimetableScreen,
    builder: (context, state) {
      final args = state.extra as TodayTimetableParameters;
      return ChangeNotifierProvider(
        create: (_) => TimetablesProvider(),
        child: AllDayTimetableScreen(
          timetableType: args.timetableType,
          studentId:
              args.studentId != null
                  ? int.tryParse(args.studentId ?? "")
                  : null,
        ),
      );
    },
  ),

  // ***********************************************************

  // ********************HOMEWORKS********************************
  // homework listing screen
  GoRoute(
    path: '/homeworkLisitingScreen',
    name: RouteConstants.homeworkLisitingScreen,
    builder: (context, state) {
      final homeworkParams = state.extra as HomeworkParameters;
      return HomeworksListingScreen(homeworkParams: homeworkParams);
    },
  ),

  // Homework details screen
  GoRoute(
    path: '/homeworkDetailsScreen',
    name: RouteConstants.homeworkDetailsScreen,
    builder: (context, state) {
      final homeworkParams = state.extra as HomeworkParameters;
      return HomeworkDetailsScreen(homeworkParams: homeworkParams);
    },
  ),

  // ********************HOMEWORKS END********************************
];

class TodayTimetableParameters {
  final TimetableType timetableType;
  final String? studentId;

  TodayTimetableParameters({required this.timetableType, this.studentId});
}

class HomeworkParameters {
  final HomeworkViewerType viewerType;
  final int? homeworkId;
  final int? studentId;

  HomeworkParameters({
    required this.viewerType,
    this.homeworkId,
    this.studentId,
  });
}
