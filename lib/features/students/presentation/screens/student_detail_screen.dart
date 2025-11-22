import 'package:acadobs/core/utils/profile_container_shimmer.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/chats/data/models/chat_model.dart';
import 'package:acadobs/features/chats/presentation/provider/chat_provider.dart';
import 'package:acadobs/features/parents/presentation/screens/payment_screen.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/students/presentation/widgets/leave_letter_screen.dart';
import 'package:acadobs/features/students/presentation/widgets/student_acheivement_tab.dart';
import 'package:acadobs/features/students/presentation/widgets/student_attendence_tab.dart';
import 'package:acadobs/features/students/presentation/widgets/student_exam_detail_screen.dart';
import 'package:acadobs/features/students/presentation/widgets/student_homework_page.dart';
import 'package:acadobs/features/students/presentation/widgets/student_notice_tab.dart';
import 'package:acadobs/features/students/presentation/widgets/student_profile_tab.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class StudentDetailScreen extends StatefulWidget {
  final int studentId;
  final bool forStaff;

  const StudentDetailScreen({
    super.key,
    required this.studentId,
    required this.forStaff,
  });

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late StudentProvider studentProvider;
  @override
  void initState() {
    studentProvider = context.read<StudentProvider>();
    studentProvider.fetchStudentDetails(
      studentId: widget.studentId,
      forStaff: widget.forStaff,
    );
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
              SliverAppBar(
                expandedHeight: 0,
                floating: true,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                title: Text(
                  "Student Profile",
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
                actions: [
                  if (widget.forStaff)
                    Consumer2<StudentProvider, ChatProvider>(
                      builder: (context, studentProvider, chatProvider, _) {
                        final student = studentProvider.individualStudent;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: IconButton(
                            onPressed: () {
                              context
                                  .pushNamed(
                                    RouteConstants.chatScreen,
                                    extra: ChatModel(
                                      opponentId: student?.user?.id ?? 0,
                                      opponentName: student?.user?.name ?? "",
                                      studentId: student?.id,
                                    ),
                                  )
                                  .then((_) {
                                    if (!mounted) return;
                                    chatProvider.loadUsersList();
                                  });
                            },
                            icon: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                size: 20,
                                // color: Color(0xFF35C2C1),
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),

              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Profile Section
                      Consumer<StudentProvider>(
                        builder: (context, provider, _) {
                          final student = provider.individualStudent;

                          if (provider.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(20),
                              child: ProfileContainerShimmer(),
                            );
                          }

                          return Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(9),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Profile Image & Name
                                Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF35C2C1),
                                            Color(0xFF00AEF0),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(
                                              0xFF35C2C1,
                                            ).withAlpha(68),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child:
                                          student?.image?.isNotEmpty == true
                                              ? ClipOval(
                                                child: Image.network(
                                                  student!.image!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return Center(
                                                      child: Text(
                                                        student
                                                                    .fullName
                                                                    .isNotEmpty ==
                                                                true
                                                            ? student
                                                                .fullName[0]
                                                                .toUpperCase()
                                                            : "S",
                                                        style: const TextStyle(
                                                          fontSize: 40,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                              : Center(
                                                child: Text(
                                                  student
                                                              ?.fullName
                                                              .isNotEmpty ==
                                                          true
                                                      ? student!.fullName[0]
                                                          .toUpperCase()
                                                      : "S",
                                                  style: const TextStyle(
                                                    fontSize: 40,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                    ),
                                  ],
                                ),

                                // Student Name
                                Text(
                                  student?.fullName ?? "Student Name",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Class Badge
                                if (student?.classGrade?.classname != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF35C2C1),
                                          Color(0xFF00AEF0),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      student!.classGrade!.classname,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: () {
                            context.pushNamed(RouteConstants.prediction);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome),
                              SizedBox(width: 10),
                              Text(
                                "See AI Prediction",
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
                sliver: SliverAppBar(
                  pinned: true,

                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: TabBar(
                        tabAlignment: TabAlignment.start,
                        isScrollable: true,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade600,
                        indicatorSize: TabBarIndicatorSize.label,
                        dividerColor: Colors.transparent,
                        indicatorColor: Colors.black,
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        indicator: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(34),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        tabs: [
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Dashboard"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Acheivement"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Exam"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Homework"),
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Leave Request"),
                            ),
                          ),
                          if (!widget.forStaff) ...[
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text("Payment"),
                              ),
                            ),
                          ],
                          if (!widget.forStaff) ...[
                            Tab(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text("Notices"),
                              ),
                            ),
                          ],

                          Tab(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text("Profile"),
                            ),
                          ),
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
                // dashboard
                StudentAttendenceTab(
                  studentId: widget.studentId,
                  date: DateFormat("yyyy-MM-dd").format(DateTime.now()),
                  forStaff: widget.forStaff,
                ),

                //acheivment
                StudentAcheivementTab(
                  studentId: widget.studentId,
                  forStaff: widget.forStaff,
                ),

                //exam
                StudentExamDetailScreen(
                  studentId: widget.studentId,
                  forStaff: widget.forStaff,
                ),

                // homework
                Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    final student = provider.individualStudent;

                    return StudentHomeworkPage(
                      forStaff: widget.forStaff,
                      studentId: widget.studentId,
                      guardianIdForChat: student?.user?.id ?? 0,
                      guardianNameForChat: student?.user?.name ?? "",
                    );
                  },
                ),

                //leave requst
                LeaveLetterScreen(
                  studentId: widget.studentId,
                  forStaff: widget.forStaff,
                ),

                //payment
                if (!widget.forStaff) ...[
                  PaymentScreen(
                    studentId: widget.studentId,
                    forParent: widget.forStaff,
                  ),
                ],

                // notices
                if (!widget.forStaff)
                  StudentNoticeTab(
                    studentId: widget.studentId,
                    forStaff: widget.forStaff,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
