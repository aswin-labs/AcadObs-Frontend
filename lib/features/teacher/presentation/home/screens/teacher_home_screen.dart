import 'package:acadobs/core/netwok/network_provider.dart';
import 'package:acadobs/core/netwok/screens/offline_banner.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/notices/presentation/provider/notice_provider.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_bottomsheet.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/teacher_attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/award_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/build_substitution_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/build_time_table_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/check_in_widget.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/event_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/fab_option_dialog.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/news_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/notice_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/quick_action_card.dart';
import 'package:acadobs/features/timetable/presentation/provider/time_table_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/profile_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  late EventProvider eventProvider;
  late NoticeProvider noticeProvider;
  late NewsProvider newsProvider;
  late TimeTableProvider timeTableProvider;
  late StudentLeaveRequestProvider studentLeaveRequestProvider;
  late TeacherAttendanceProvider teacherAttendanceProvider;
  late AchievementProvider achievementProvider;

  @override
  void initState() {
    super.initState();
    eventProvider = context.read<EventProvider>();
    noticeProvider = context.read<NoticeProvider>();
    newsProvider = context.read<NewsProvider>();
    timeTableProvider = context.read<TimeTableProvider>();
    studentLeaveRequestProvider = context.read<StudentLeaveRequestProvider>();
    teacherAttendanceProvider = context.read<TeacherAttendanceProvider>();
    achievementProvider = context.read<AchievementProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshAllData();
    });
  }

  Future<void> refreshAllData() async {
    await Future.wait([
      eventProvider.fetchLatestEvents(forStaff: true),
      noticeProvider.fetchLatestNotices(),
      newsProvider.fetchLatestNews(limit: 3, forStaff: true),
      timeTableProvider.fetchTimeTable(forStaff: true),
      studentLeaveRequestProvider.getLeaveRequestNotification(),
      teacherAttendanceProvider.getTodayAttendanceStatus(),
      achievementProvider.fetchLatestSchoolAchievements(forStaff: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refreshAllData,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App Bar with gradient
                SliverAppBar(
                  expandedHeight: 140,
                  floating: false,
                  pinned: true,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,

                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getGreeting(),
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(203),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        refreshAllData();
                                      },
                                      child: Text(
                                        "Teacher",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'EEEE, dd MMMM',
                                      ).format(DateTime.now()),
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(180),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ProfileIcon(
                                icon: CupertinoIcons.profile_circled,
                                ontap: () {
                                  context.pushNamed(
                                    RouteConstants.profileScreen,
                                    extra: true,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Check-in Card
                        CheckInWidget(),
                        const SizedBox(height: 20),

                        // Quick Actions Section
                        _buildSectionHeader("Quick Actions", null),
                        const SizedBox(height: 12),
                        _buildQuickActions(context),
                        const SizedBox(height: 24),

                        // Today's Schedule Section
                        buildTimeTableSection(context),
                        const SizedBox(height: 12),
                        buildSubstitutionSection(context),

                        _buildSectionHeader("Updates", null),
                        // Latest Notices
                        NoticeSection(),
                        // Latest Events
                        EventSection(),
                        // Latest News
                        NewsSection(),
                        const SizedBox(height: 20),
                        // Awards and Accomplishments
                        AwardSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (!networkProvider.isConnected) OfflineBanner(),
        ],
      ),
      floatingActionButton: CommonFloatingButton(
        onPressed:
            () => showDialog(
              context: context,
              builder: (context) => FabOptionsDialog(),
            ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                icon: Icons.assignment_outlined,
                label: 'Homework',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                ),
                onTap: () => context.pushNamed(RouteConstants.homeworks),
              ),
            ),
            Expanded(
              child: QuickActionCard(
                icon: Icons.check_circle_outline,
                label: 'Attendance',
                gradient: const LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                ),
                onTap: () => showAttendanceBottomSheet(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Consumer<StudentLeaveRequestProvider>(
          builder: (context, provider, _) {
            return QuickActionCard(
              icon: Icons.description_outlined,
              label: 'Student Leave Requests',
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
              ),
              notificationCount: provider.leaveNotificationCount,
              onTap: () => context.pushNamed(RouteConstants.studentLeaveLetter),
              isFullWidth: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: Text(
              'View All',
              style: TextStyle(
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
