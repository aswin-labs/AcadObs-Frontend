import 'dart:ui';

import 'package:acadobs/core/netwok/network_provider.dart';
import 'package:acadobs/core/netwok/screens/offline_banner.dart';
import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';

import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/events/presentation/widgets/event_card.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/news/presentation/widgets/news_card.dart';
import 'package:acadobs/features/notices/presentation/provider/notice_provider.dart';
import 'package:acadobs/features/notices/presentation/widgets/notice_card.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/students/presentation/widgets/time_table_card.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_bottomsheet.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/teacher_attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/check_in_widget.dart';
import 'package:acadobs/features/timetable/presentation/provider/time_table_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';

import 'package:acadobs/shared/widgets/profile_icon.dart';
import 'package:acadobs/shared/widgets/time_table_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
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

  @override
  void initState() {
    super.initState();
    eventProvider = context.read<EventProvider>();
    noticeProvider = context.read<NoticeProvider>();
    newsProvider = context.read<NewsProvider>();
    timeTableProvider = context.read<TimeTableProvider>();
    studentLeaveRequestProvider = context.read<StudentLeaveRequestProvider>();
    teacherAttendanceProvider = context.read<TeacherAttendanceProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshAllData();
    });
  }

  Future<void> refreshAllData() async {
    await Future.wait([
      eventProvider.fetchHomeLatestEvents(limit: 3, forStaff: true),
      noticeProvider.fetchHomeLatestNotices(limit: 3),
      newsProvider.fetchHomeLatestNews(limit: 3, forStaff: true),
      timeTableProvider.fetchTimeTable(forStaff: true),
      studentLeaveRequestProvider.getLeaveRequestNotification(),
      teacherAttendanceProvider.getTodayAttendanceStatus(),
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
                        _buildTimeTableSection(context),
                        const SizedBox(height: 12),
                        _buildSubstitutionSection(context),

                        _buildSectionHeader("Updates", null),
                        //notice listing in the teacher home screen
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
                                context.pushNamed(
                                  RouteConstants.noticeListscreen,
                                );
                              },
                              child: Text(
                                "View",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Consumer<NoticeProvider>(
                          builder: (context, provider, _) {
                            final notices = provider.latestNotices;
                            if (provider.isLoading && notices.isEmpty) {
                              return const Center(child: CommonShimmerTile());
                            }
                            if (notices.isEmpty) {
                              return emptyScreen(
                                message: "No Notices Avaliable",
                                heightMultiplier: 5,
                              );
                            }
                            return Column(
                              children:
                                  notices.map((notice) {
                                    final date =
                                        "${notice.createdAt.day.toString().padLeft(2, '0')}-${notice.createdAt.month.toString().padLeft(2, '0')}-${notice.createdAt.year}";
                                    return NoticeCard(
                                      title: capitalizeEachWord(
                                        notice.title ?? "N/A",
                                      ),
                                      date: date,
                                      icon: Icons.notifications,
                                      time: TimeFormatter.formatTime(
                                        notice.createdAt,
                                      ),
                                      onTap: () {
                                        context.pushNamed(
                                          RouteConstants.noticedetails,
                                          extra: notice,
                                        );
                                      },
                                    );
                                  }).toList(),
                            );
                          },
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
                                context.pushNamed(
                                  RouteConstants.eventListscreen,
                                  extra: true,
                                );
                              },
                              child: Text(
                                "View",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),

                        //listing latest events
                        Consumer<EventProvider>(
                          builder: (context, provider, _) {
                            final events = provider.latestEvent;
                            if (provider.isLoading) {
                              return Center(child: CommonShimmerTile());
                            } else if (events.isEmpty) {
                              return emptyScreen(
                                message: "No Events Avaliable",
                                heightMultiplier: 5,
                              );
                            }

                            return Column(
                              children:
                                  events.map((events) {
                                    return EventCard(
                                      event: events,

                                      onViewTap: () {
                                        context.pushNamed(
                                          RouteConstants.eventlistdetails,
                                          extra: events,
                                        );
                                      },
                                      time: TimeFormatter.formatTime(
                                        events.createdAt ?? DateTime.now(),
                                      ),
                                    );
                                  }).toList(),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Text(
                              "News",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            TextButton(
                              onPressed: () {
                                context.pushNamed(
                                  RouteConstants.newsDetailsScreen,
                                  extra: true,
                                );
                              },
                              child: Text(
                                "View",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),

                        //listing news
                        Consumer<NewsProvider>(
                          builder: (context, provider, _) {
                            final news = provider.latestNews;
                            if (provider.isLoading) {
                              return Center(child: CommonShimmerTile());
                            } else if (news.isEmpty) {
                              return emptyScreen(
                                message: "No News Avaliable",
                                heightMultiplier: 5,
                              );
                            }

                            return Column(
                              children:
                                  news.map((news) {
                                    final formattedDate = DateFormat(
                                      'dd-MM-yy',
                                    ).format(news.date);
                                    return NewsCard(
                                      news: news,
                                      button: () {
                                        context.pushNamed(
                                          RouteConstants.newsScreen,
                                          extra: news,
                                        );
                                      },
                                      date: formattedDate,
                                      time: TimeFormatter.formatTime(
                                        news.createdAt,
                                      ),
                                      title: capitalizeEachWord(news.title),
                                      content: news.content,
                                    );
                                  }).toList(),
                            );
                          },
                        ),
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
              child: _QuickActionCard(
                icon: Icons.assignment_outlined,
                label: 'Homework',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                ),
                onTap: () => context.pushNamed(RouteConstants.homeworks),
              ),
            ),
            Expanded(
              child: _QuickActionCard(
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
            return _QuickActionCard(
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

// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final int? notificationCount;
  final bool isFullWidth;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.notificationCount,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Container(
              height: 85,
              width: isFullWidth ? double.infinity : null,
              margin: const EdgeInsets.all(2),

              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withAlpha(68),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              // padding: EdgeInsets.all(10),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(34),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (notificationCount != null && notificationCount! > 0)
          Positioned(
            top: -3,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Text(
                '${notificationCount!}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// FAB Dialog
class FabOptionsDialog extends StatelessWidget {
  const FabOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withAlpha(68)),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 24,
          left: 24,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(34),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OptionTile(
                    icon: Icons.note_alt_outlined,
                    label: 'Leave Requests',
                    iconColor: Color(0xFF26A69A),
                    onTap: () {
                      context.pushNamed(RouteConstants.staffLeaveRequestHome);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _OptionTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Students',
                    iconColor: Color(0xFF1E88E5),
                    onTap: () {
                      context.pushNamed(RouteConstants.studentListing);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _OptionTile(
                    icon: LucideIcons.badgeCheck,
                    label: 'Achievements',
                    iconColor: Color(0xFFFF6B6B),
                    onTap: () {
                      context.pushNamed(RouteConstants.achievementList);
                      Navigator.pop(context);
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
  final Color iconColor;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(23),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

Widget _buildSubstitutionSection(BuildContext context) {
  return Consumer<TimeTableProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return const TimeTableShimmer();
      }

      if (provider.substitution.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.swap_horiz, color: Color(0xFFFF9800), size: 20),
              const SizedBox(width: 8),
              Text(
                "Substitution Classes",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              itemCount: provider.substitution.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final item = provider.substitution[index];
                return TimeTableCard(
                  forStaff: true,
                  periodnumber: item.timeTable?.periodNumber ?? 0,
                  subject: item.subject?.subjectName ?? "",
                  description: item.timeTable?.classGrade?.classname ?? "",
                );
              },
            ),
          ),
        ],
      );
    },
  );
}

Widget _buildTimeTableSection(BuildContext context) {
  return Consumer<TimeTableProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return const TimeTableShimmer();
      }

      if (provider.timetableForStaff.isEmpty) {
        return const SizedBox.shrink();
      }

      final screenWidth = MediaQuery.of(context).size.width;

      double maxCrossAxisExtent;
      if (screenWidth >= 1200) {
        maxCrossAxisExtent = 250;
      } else if (screenWidth >= 800) {
        maxCrossAxisExtent = 200; // tablet
      } else {
        maxCrossAxisExtent = 150; // phone
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.schedule, color: Color(0xFF2196F3), size: 20),
              SizedBox(width: 8),
              Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          GridView.builder(
            itemCount: provider.timetableForStaff.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final item = provider.timetableForStaff[index];
              return TimeTableCard(
                forStaff: true,
                periodnumber: item.periodNumber ?? 0,
                subject: item.subject?.subjectName ?? "N/A",
                description: item.classGrade?.classname ?? "N/A",
              );
            },
          ),
        ],
      );
    },
  );
}
