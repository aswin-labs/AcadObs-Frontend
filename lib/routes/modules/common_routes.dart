import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/presentation/screens/user_roles_screen.dart';
import 'package:acadobs/presentation/bottom_nav/presentation/bottom_nav_screen.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:go_router/go_router.dart';

final List<GoRoute> commonRoutes = [
  GoRoute(
    path: '/',
    name: RouteConstants.userRolesScreen,
    builder: (context, state) => UserRolesScreen(),
  ),
  GoRoute(
    path: '/bottomNavScreen',
    name: RouteConstants.bottomNavScreen,
    builder: (context, state) {
      final UserType userType = state.extra as UserType;
      return BottomNavScreen(userType: userType);
    },
  ),
];
