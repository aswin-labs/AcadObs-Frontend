import 'package:acadobs/core/theme/colors/app_colors.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/admin/presentation/home/admin_home_screen.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/superadmin/presentation/school_classes/screens/school_classes_screen.dart';
import 'package:acadobs/features/superadmin/presentation/school_subjects/screens/school_subjects_screen.dart';
import 'package:acadobs/features/superadmin/presentation/schools/screens/schools_list_screen.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/attendance_home_screen.dart';
import 'package:acadobs/features/teacher/presentation/duties/screens/duty_home_screen.dart';
import 'package:acadobs/features/teacher/presentation/home/screens/teacher_home_screen.dart';
import 'package:acadobs/features/teacher/presentation/marks/screens/marks_home_screen.dart';
import 'package:acadobs/features/teacher/presentation/payments/screens/payments_home_screen.dart';
import 'package:acadobs/shared/bottom_nav/controller/bottom_navbar_controller.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class BottomNavScreen extends StatefulWidget {
  final UserType userType;
  const BottomNavScreen({super.key, required this.userType});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  DateTime? lastPressed;

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
      return [
        AdminHomeScreen(),
        Center(child: Text("Admin")),
      ];
    } else if (userType == UserType.teacher) {
      return [
        TeacherHomeScreen(),
        AttendanceHomeScreen(),
        MarksHomeScreen(),
        DutyHomeScreen(),
        PaymentsHomeScreen(),
      ];
    } else if (userType == UserType.parent) {
      return [
        // HomePage(),
        // EventsPage(),
        // NoticePage(),
        // PaymentSelection(),
        Center(child: Text("Parent")),
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
        _bottomNavItem(icon: LucideIcons.creditCard, label: 'Payments'),
      ];
    } else if (userType == UserType.parent) {
      return [
        _bottomNavItem(icon: LucideIcons.home, label: 'Home'),
        _bottomNavItem(icon: LucideIcons.calendarDays, label: 'Events'),
        _bottomNavItem(icon: LucideIcons.bell, label: 'Notice'),
        _bottomNavItem(icon: LucideIcons.creditCard, label: 'Payment'),
        _bottomNavItem(icon: LucideIcons.messageSquare, label: 'Chat'),
      ];
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomNavProvider = Provider.of<BottomNavbarController>(context);
    final int currentIndex = bottomNavProvider.currentIndex;
    final pages = _getPages(widget.userType);
    final navItems = _getBottomNavItems(widget.userType);
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
