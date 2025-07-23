import 'dart:ui';
import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/features/parents/data/models/event_model.dart';
import 'package:acadobs/features/parents/presentation/events/widgets/event_card.dart';
import 'package:acadobs/features/parents/presentation/notices/widgets/notice_card.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_bottomsheet.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/user_model.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:acadobs/shared/widgets/custom_button_container.dart';
import 'package:acadobs/shared/widgets/custom_name_container.dart';
import 'package:acadobs/shared/widgets/profile_icon.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: "HomeScreen"),
      body: Padding(
        padding: context.paddingHorizontal,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hi,",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 48,
                        ),
                      ),
                      Text(
                        "Arun",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF555555),
                          fontSize: 36,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  ProfileIcon(
                    image: "assets/school.jpg",
                    ontap: () {
                      // print('teacher profile');
                      context.pushNamed(
                        RouteConstants.profileScreen,
                        extra: UserModel(
                          name: "Teacher One",
                          role: "Teacher",
                          email: "teacher@gmail.com",
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 30),
              Row(
                children: [
                  CustomNameContainer(text: "Student", onPressed: () => context.pushNamed(RouteConstants.studentListing),),
                  SizedBox(width: 10),
                  CustomNameContainer(text: "Parent", onPressed: () {}),
                ],
              ),

              SizedBox(height: 20),
              CustomButtonContainer(
                color: Color(0xFF22AE22),
                text: "Home Work",
                ontap: () => context.pushNamed(RouteConstants.homeworks),
              ),
              SizedBox(height: 10),
              CustomButtonContainer(
                color: Color(0xFF010101),
                text: "Attendence",
                ontap: () => showAttendanceBottomSheet(context),
              ),

              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Notices",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      // () => context.pushNamed(RouteConstants.staffLeaveRequestHome),
                      context.pushNamed(RouteConstants.noticeListscreen);
                    },
                    child: Text("View", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              NoticeCard(
                title: "Notice 1",
                date: "22-07-2025",
                icon: Icons.notifications,
                time: "15:19",
                onTap: () {},
              ),
              NoticeCard(
                title: "Notice 2",
                date: "22-07-2025",
                icon: Icons.notifications,
                time: "14:19",
                onTap: () {},
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Events",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(RouteConstants.eventListscreen);
                    },
                    child: Text("View", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              SizedBox(height: 10),
              EventCard(
                event: Events(title: 'event 1'), //dummmy
                onViewTap: () {},
                time: "22-07-2025",
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        shape: CircleBorder(),
        child: Icon(LucideIcons.plus, color: Colors.grey),
        onPressed:
            () => showDialog(
              context: context,
              builder: (context) => const FabOptionsDialog(),
            ),
      ),
    );
  }
}

class FabOptionsDialog extends StatelessWidget {
  const FabOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withAlpha(50)),
          ),
        ),

        // Floating card at bottom right
        Positioned(
          bottom: 90,
          right: 90,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFE6E6E6),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OptionTile(
                    icon: Icons.note_alt_outlined,
                    label: 'Leave Requests',
                    onTap: ()  => context.pushNamed(
                          RouteConstants.staffLeaveRequestHome,
                        ),
                  ),
                  Divider(height: 0, color: Color(0xFFE6E6E6)),
                  _OptionTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Subjects',
                    onTap: () {
                      // Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(label, style: TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }
}



      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.black,
      //   shape: CircleBorder(),
      //   onPressed: () {
      //     // Your logic here
      //     showModalBottomSheet(
      //       backgroundColor: Colors.transparent,
      //       context: context,
      //       builder: (context) => _buildFabMenu(context),
      //     );
      //   },
      //   child: Icon(LucideIcons.calendarPlus),
      // ),

      // CustomScrollView(
      //   slivers: [
      //     SliverPadding(
      //       padding: context.paddingHorizontal,
      //       sliver: SliverToBoxAdapter(
      //         child: Column(
      //           children: [
      //             SizedBox(height: Responsive.height * 2),
      //             CustomButtonContainer(
      //               color: AppColors.black,
      //               text: "Take Attendance",
      //               ontap: () => showAttendanceBottomSheet(context),
      //             ),
      //             SizedBox(height: Responsive.height * 2),
      //             CustomButtonContainer(
      //               color: AppColors.black,
      //               text: "Leave Request",
      //               ontap: () => context.pushNamed(RouteConstants.staffLeaveRequestHome),
      //             ),
      //             SizedBox(height: Responsive.height * 2),
      //              CustomButtonContainer(
      //               color: AppColors.black,
      //               text: "Students",
      //               ontap:
      //                   () => context.pushNamed(RouteConstants.studentListing),
      //             ),
      //              SizedBox(height: Responsive.height * 2),
      // CustomButtonContainer(
      //   color: AppColors.black,
      //   text: "Homework",
      //   ontap: (){},
      // ),
      //             ],
      //           ),
      //         ),
      //       ),
      //     ],
      // ),