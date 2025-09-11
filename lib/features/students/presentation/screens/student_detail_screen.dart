import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/profile_container_shimmer.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parents/presentation/screens/payment_screen.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
// import 'package:acadobs/features/students/presentation/widgets/daily_attendance_widget.dart';
import 'package:acadobs/features/students/presentation/widgets/leave_letter_screen.dart';
import 'package:acadobs/features/students/presentation/widgets/student_acheivement_tab.dart';
import 'package:acadobs/features/students/presentation/widgets/student_attendence_tab.dart';
import 'package:acadobs/features/students/presentation/widgets/student_exam_detail_screen.dart';
import 'package:acadobs/features/students/presentation/widgets/student_homework_page.dart';
import 'package:acadobs/features/students/presentation/widgets/student_notice_tab.dart';
import 'package:acadobs/features/students/presentation/widgets/student_profile_tab.dart';
import 'package:acadobs/shared/widgets/profile_container.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;
  final bool forParent;
  const StudentDetailScreen({
    super.key,
    required this.studentId,
    required this.forParent,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late StudentProvider studentProvider;
  @override
  void initState() {
    studentProvider = context.read<StudentProvider>();
    studentProvider.fetchStudentDetails(studentId: widget.studentId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: context.paddingHorizontal.add(
                    EdgeInsets.only(top: Responsive.height * 5),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFD9D9D9),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Text(
                            textAlign: TextAlign.center,
                            "Student",
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 22,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(LucideIcons.messageSquarePlus),
                        ],
                      ),
                      SizedBox(height: Responsive.height * 3),
                      Consumer<StudentProvider>(
                        builder: (context, provider, _) {
                          final student = provider.individualStudent;
                          if (provider.isLoading) {
                            return ProfileContainerShimmer();
                          }
                          return ProfileContainer(
                            imagePath: student?.image ?? "",
                            name: student?.fullName ?? "",
                            present: "1",
                            absent: "2",
                            late: "3",
                            description: student?.classGrade?.classname,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.only(bottom: Responsive.height * 2),
              ),
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  pinned: true,

                  // backgroundColor: Colors.grey.shade200,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.black,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        tabs: const [
                          Tab(text: "Dashboard"),
                          Tab(text: "Acheivement"),
                          Tab(text: "Exam"),
                          Tab(text: "Homework"),
                          Tab(text: 'Leave request'),
                          Tab(text: "Payment"),
                          Tab(text: "Notices"),
                          Tab(text: "Profile"),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: Padding(
            padding: EdgeInsets.only(top: Responsive.height * 5),
            child: TabBarView(
              children: [
                // dashboardt
                StudentAttendenceTab(
                  studentId: widget.studentId,
                  date: "2025-08-20",
                ),

                // Text("Dashboard"),

                //acheivment
                Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    final student = provider.individualStudent;
                    if (student == null) {
                      return SizedBox.shrink();
                    }
                    return StudentAcheivementTab(studentId: widget.studentId);
                  },
                ),

                //exam
                StudentExamDetailScreen(
                  studentId: widget.studentId,
                  forParent: widget.forParent,
                ),

                //homework
                StudentHomeworkPage(
                  forParent: widget.forParent,
                  studentId: widget.studentId,
                ),

                //leave requst
                Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    final student = provider.individualStudent;
                    if (student == null) {
                      return SizedBox.shrink();
                    }
                    return LeaveLetterScreen(
                      studentId: widget.studentId,
                      forParent: widget.forParent,
                    );
                  },
                ),

                //payment
                Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    final student = provider.individualStudent;
                    if (student == null) {
                      return SizedBox.shrink();
                    }
                    return PaymentScreen(
                      studentId: widget.studentId,
                      forParent: widget.forParent,
                    );
                  },
                ),

                //notices
                Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    final student = provider.individualStudent;
                    if (student == null) {
                      return SizedBox.shrink();
                    }
                    return StudentNoticeTab(
                      studentId: widget.studentId,
                      forParent: widget.forParent,
                    );
                  },
                ),

                // Profile
                Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    final student = provider.individualStudent;
                    if (student == null) {
                      return SizedBox.shrink();
                    }
                    return StudentProfileTab(student: student);
                  },
                ),

                // //leave requst
                // Consumer<StudentProvider>(
                //   builder: (context, provider, _) {
                //     final student = provider.individualStudent;
                //     if (student == null) {
                //       return SizedBox.shrink();
                //     }
                //     return LeaveLetterScreen();
                //   },
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
