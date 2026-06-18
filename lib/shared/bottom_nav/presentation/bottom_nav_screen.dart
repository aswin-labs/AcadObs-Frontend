import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/admin/presentation/home/admin_home_screen.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
// import 'package:acadobs/features/chats/presentation/screens/chats_home_screen.dart';
import 'package:acadobs/features/events/presentation/screens/event_listing_screen.dart';
import 'package:acadobs/features/marks/presentation/screens/marks_home_screen.dart';
import 'package:acadobs/features/news/presentation/screens/news_full_screen.dart';
import 'package:acadobs/features/parents/presentation/screens/parent_home_screen.dart';
import 'package:acadobs/features/parents/presentation/screens/teachers_listing_screen.dart';
import 'package:acadobs/features/superadmin/presentation/school_classes/screens/school_classes_screen.dart';
import 'package:acadobs/features/superadmin/presentation/school_subjects/screens/school_subjects_screen.dart';
import 'package:acadobs/features/superadmin/presentation/schools/screens/schools_list_screen.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/attendance_home_screen.dart';
import 'package:acadobs/features/teacher/presentation/duties/screens/duty_home_screen.dart';
import 'package:acadobs/features/teacher/presentation/home/screens/teacher_home_screen.dart';
import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/bottom_nav/controller/bottom_navbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class BottomNavScreen extends StatefulWidget {
  final UserType? userType;
  const BottomNavScreen({super.key, this.userType});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  DateTime? lastPressed;
  UserType? _userType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userType = widget.userType;
    if (_userType == null) {
      _loadUserType();
    }
  }

  Future<void> _loadUserType() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final role = await AuthStorageService().getUserRole();
      if (role == 'guardian') {
        _userType = UserType.parent;
      } else if (role == 'teacher') {
        _userType = UserType.teacher;
      } else if (role == 'admin') {
        _userType = UserType.schoolAdmin;
      } else if (role != null) {
        _userType = UserType.superAdmin;
      } else {
        if (mounted) {
          context.goNamed(RouteConstants.loginScreen);
        }
        return;
      }
    } catch (e) {
      log("Error loading user type in BottomNavScreen: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Define pages for each user type
  List<Widget> _getPages(UserType userType) {
    if (userType == UserType.superAdmin) {
      return [
        const SchoolsListScreen(),
        const SchoolClassesScreen(),
        const SchoolSubjectsScreen(),
      ];
    }
    if (userType == UserType.schoolAdmin) {
      return [AdminHomeScreen(), Center(child: Text("Admin"))];
    } else if (userType == UserType.teacher) {
      return [
        TeacherHomeScreen(),
        AttendanceHomeScreen(),
        MarksHomeScreen(),
        DutyHomeScreen(),
        // ChatsHomeScreen(),
      ];
    } else if (userType == UserType.parent) {
      return [
        ParentHomeScreen(),
        EventListingScreen(forStaff: false),
        NewsListingScreen(forStaff: false),
        // ChatsHomeScreen(forParent: true),
        TeachersListingScreen(),
      ];
    } else {
      return [];
    }
  }

  // Define BottomNavigationBarItems for each user type
  List<BottomNavigationBarItem> _getBottomNavItems(UserType userType) {
    if (userType == UserType.superAdmin) {
      return [
        _bottomNavItem(icon: LucideIcons.home, label: 'Schools'),
        _bottomNavItem(icon: LucideIcons.bookOpen, label: 'Classes'),
        _bottomNavItem(icon: LucideIcons.fileText, label: 'Subjects'),
      ];
    } else if (userType == UserType.schoolAdmin) {
      return [
        _bottomNavItem(icon: LucideIcons.home, label: 'Home'),
        _bottomNavItem(icon: LucideIcons.listTodo, label: 'Duties'),
        _bottomNavItem(icon: LucideIcons.fileBarChart2, label: 'Reports'),
        _bottomNavItem(icon: LucideIcons.bell, label: 'Notice'),
        _bottomNavItem(icon: LucideIcons.creditCard, label: 'Payments'),
      ];
    } else if (userType == UserType.teacher) {
      return [
        _bottomNavItem(icon: LucideIcons.home, label: 'Home'),
        _bottomNavItem(icon: LucideIcons.calendarCheck, label: 'Attendance'),
        _bottomNavItem(icon: LucideIcons.fileText, label: 'Marks'),
        _bottomNavItem(icon: LucideIcons.listTodo, label: 'Duties'),
        // _bottomNavItem(icon: LucideIcons.messageSquarePlus, label: 'Chats'),
      ];
    } else if (userType == UserType.parent) {
      return [
        _bottomNavItem(icon: LucideIcons.home, label: 'Home'),
        _bottomNavItem(icon: LucideIcons.calendarDays, label: 'Events'),
        _bottomNavItem(icon: LucideIcons.bell, label: 'News'),
        // _bottomNavItem(icon: LucideIcons.messageSquare, label: 'Chat'),
        _bottomNavItem(icon: LucideIcons.users, label: 'Teachers'),
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _userType == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    final bottomNavProvider = Provider.of<BottomNavbarController>(context);
    final int currentIndex = bottomNavProvider.currentIndex;
    final pages = _getPages(_userType!);
    final navItems = _getBottomNavItems(_userType!);

    if (currentIndex >= pages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        bottomNavProvider.setIndex(0);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: SizedBox(
        height: Responsive.height * 8,
        child: BottomNavigationBar(
          backgroundColor: AppColors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          selectedItemColor:
              Colors.black, // handled by BottomNavigationBar itself
          unselectedItemColor: Color(0xFF848484),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          onTap: (index) {
            bottomNavProvider.setIndex(index);
          },
          items: navItems,
        ),
      ),
      // ),
    );
  }

  BottomNavigationBarItem _bottomNavItem({
    required IconData icon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon, size: 24),
      activeIcon: Icon(icon, size: 26),
      label: label,
    );
  }
}
