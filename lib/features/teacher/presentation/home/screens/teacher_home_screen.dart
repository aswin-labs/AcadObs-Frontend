import 'dart:ui';

import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
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
import 'package:acadobs/shared/models/user_model.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/custom_button_container.dart';
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
      eventProvider.fetchHomeLatestEvents(limit: 3, forStaff: true);
      noticeProvider.fetchHomeLatestNotices(limit: 3);
      newsProvider.fetchHomeLatestNews(limit: 3, forStaff: true);
      timeTableProvider.fetchTimeTable(forStaff: true);
      studentLeaveRequestProvider.getLeaveRequestNotification();
      teacherAttendanceProvider.getTodayAttendanceStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: context.paddingHorizontal.add(
          EdgeInsets.only(top: Responsive.height * 7),
        ),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
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
                        "Teacher",
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
                    icon: CupertinoIcons.profile_circled,
                    ontap: () {
                      context.pushNamed(
                        RouteConstants.profileScreen,
                        extra: UserModel(role: "teacher"),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 30),

              CheckInWidget(),
              SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: CustomButtonContainer(
                      color: Color(0XFF22AE22),
                      text: "Home Work",
                      ontap: () => context.pushNamed(RouteConstants.homeworks),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CustomButtonContainer(
                      color: Color(0XFF010101),
                      text: "Attendence",
                      ontap: () => showAttendanceBottomSheet(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              //leave request with the notification alert
              Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomButtonContainer(
                    color: Color(0XFF20C997),
                    text: "Student leaves",
                    ontap: () {
                      context.pushNamed(RouteConstants.studentLeaveLetter);
                    },
                  ),

                  Positioned(
                    top: 15,
                    right: 10,
                    child: Consumer<StudentLeaveRequestProvider>(
                      builder: (context, provider, _) {
                        final pendingCount = provider.leaveNotificationCount;

                        if (pendingCount == 0) return const SizedBox();

                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              pendingCount > 99 ? '99+' : '$pendingCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
              _buildTimeTableSection(context),
              SizedBox(height: 5),
              _buildSubstitutionSection(context),
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
                      context.pushNamed(RouteConstants.noticeListscreen);
                    },
                    child: Text("View", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),

              //notice listing in the teacher home screen
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
                            title: capitalizeEachWord(notice.title ?? "N/A"),
                            date: date,
                            icon: Icons.notifications,
                            time: TimeFormatter.formatTime(notice.createdAt),
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
                    child: Text("View", style: TextStyle(color: Colors.black)),
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
                    child: Text("View", style: TextStyle(color: Colors.black)),
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
                            time: TimeFormatter.formatTime(news.createdAt),
                            title: capitalizeEachWord(news.title),
                            content: news.content,
                          );
                        }).toList(),
                  );
                },
              ),
              SizedBox(height: Responsive.height * 10),
            ],
          ),
        ),
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
            filter: ImageFilter.blur(
              sigmaX: 6,
              sigmaY: 6,
            ), // Slightly stronger blur for polish
            child: Container(
              color: Colors.black.withAlpha(77),
            ), // Softer overlay
          ),
        ),

        Positioned(
          bottom: 100,
          right: 60,
          left: 60,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(51),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
                gradient: LinearGradient(
                  // Subtle gradient for modern look
                  colors: [Colors.white, Colors.grey.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OptionTile(
                    icon: Icons.note_alt_outlined,
                    label: 'Leave Requests',
                    iconColor: Color(
                      0xFF26A69A,
                    ), // Teal to match Student Leaves
                    onTap: () {
                      context.pushNamed(RouteConstants.staffLeaveRequestHome);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ), // Softer divider
                  _OptionTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Students',
                    iconColor: Color(0xFF1E88E5), // Blue to match Attendance
                    onTap: () {
                      context.pushNamed(RouteConstants.studentListing);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  _OptionTile(
                    icon: LucideIcons.badgeCheck,
                    label: 'Achievements',
                    iconColor: Color(
                      0xFFFF6B6B,
                    ), // Coral Red to match Home Work
                    onTap: () {
                      context.pushNamed(RouteConstants.getAchievement);
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
      splashColor: Colors.grey.withAlpha(25),
      highlightColor: Colors.grey.withAlpha(12),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
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

      if (provider.error != null) {
        return _buildErrorCard(provider.error!);
      }

      if (provider.substitution.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Substitution",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 5),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: provider.substitution.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
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

Widget _buildErrorCard(String error) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.red[50],
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.red[200]!),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: Colors.red[700]),
        const SizedBox(width: 12),
        Expanded(child: Text(error, style: TextStyle(color: Colors.red[700]))),
      ],
    ),
  );
}

Widget _buildTimeTableSection(BuildContext context) {
  return Consumer<TimeTableProvider>(
    builder: (context, provider, _) {
      if (provider.isLoading) {
        return const TimeTableShimmer();
      }

      if (provider.error != null) {
        return _buildErrorCard(provider.error!);
      }

      if (provider.timetableForStaff.isEmpty) {
        return SizedBox.shrink();
      }

      return Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Today's TimeTable",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: provider.timetableForStaff.length,

              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
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
          ),
        ],
      );
    },
  );
}
