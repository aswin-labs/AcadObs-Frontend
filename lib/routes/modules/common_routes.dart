import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/presentation/screens/login_screen.dart';
import 'package:acadobs/features/authentication/presentation/screens/splash_screen.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/chats/presentation/screens/chat_screen.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/bottom_nav/presentation/bottom_nav_screen.dart';
import 'package:acadobs/shared/widgets/no_internet_screen.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> commonRoutes = [
  // Splash
  GoRoute(
    path: '/',
    name: RouteConstants.splashScreen,
    builder: (context, state) => SplashScreen(),
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
      final UserType userType = state.extra as UserType;
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
];
