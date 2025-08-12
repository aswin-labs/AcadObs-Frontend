import 'dart:ui';

import 'package:acadobs/core/extensions/context_extensions.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/core/utils/responsive.dart';
import 'package:acadobs/features/parents/presentation/events/provider/event_provider.dart';
import 'package:acadobs/features/parents/presentation/events/widgets/event_card.dart';
import 'package:acadobs/features/parents/presentation/notices/provider/notice_provider.dart';
import 'package:acadobs/features/parents/presentation/notices/widgets/notice_card.dart';
// import 'package:acadobs/features/teacher/data/models/news/new_model.dart';
import 'package:acadobs/features/teacher/presentation/attendance/widgets/attendance_bottomsheet.dart';
import 'package:acadobs/features/teacher/presentation/news/widgets/news_card.dart';
import 'package:acadobs/features/teacher/presentation/news/provider/news_provider.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/user_model.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/custom_button_container.dart';
// import 'package:acadobs/shared/widgets/custom_name_container.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<EventProvider>().fetchHomeLatestEvents(limit: 3);
    context.read<NoticeProvider>().fetchHomeLatestNotices(limit: 3);
    context.read<NewsProvider>().fetchHomeLatestNews(limit: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: context.paddingHorizontal.add(
          EdgeInsets.only(top: Responsive.height * 5),
        ),
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
                    // image: "assets/school.jpg",
                    icon: CupertinoIcons.profile_circled,
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

              // Row(
              //   children: [
              //     CustomNameContainer(
              //       text: "Student",
              //       onPressed:
              //           () => context.pushNamed(RouteConstants.studentListing),
              //     ),
              //     SizedBox(width: 10),
              //     CustomNameContainer(text: "Parent", onPressed: () {}),
              //   ],
              // ),
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
                      context.pushNamed(RouteConstants.noticeListscreen);
                    },
                    child: Text("View", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              SizedBox(height: 10),

              //notice listing in the teacher home screen
              Consumer<NoticeProvider>(
                builder: (context, provider, _) {
                  final notices = provider.latestNotices;
                  if (provider.isLoading && notices.isEmpty) {
                    return const Center(child: CommonShimmerTile());
                  }
                  if (notices.isEmpty) {
                    return Column(
                      children: [
                        Icon(
                          Icons.notifications_off_rounded,
                          color: Colors.grey,
                        ),
                        Text(
                          "No Notices avaliable",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
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
                            onTap: () {},
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
                      context.pushNamed(RouteConstants.eventListscreen);
                    },
                    child: Text("View", style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
              SizedBox(height: 10),

              //listing latest events
              Consumer<EventProvider>(
                builder: (context, provider, _) {
                  final events = provider.latestEvent;
                  if (provider.isLoading) {
                    return Center(child: CommonShimmerTile());
                  } else if (events.isEmpty) {
                    return Column(
                      children: [
                        Icon(Icons.event_busy_rounded, color: Colors.grey),
                        Text(
                          "No Events Avaliable",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children:
                        events.map((events) {
                          return EventCard(
                            event: events,

                            onViewTap: () {},
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
                      context.pushNamed(RouteConstants.newsDetailsScreen);
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
                    return Center(child: commonShimmerList());
                  } else if (news.isEmpty) {
                    return Column(
                      children: [
                        Icon(Icons.event_busy_rounded, color: Colors.grey),
                        Text(
                          "No News Avaliable",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    );
                  }

                  return Column(
                    children:
                        news.map((news) {
                          final formattedDate = DateFormat(
                            'dd-MM-yy',
                          ).format(news.date);
                          final formattedTime = DateFormat(
                            'hh:mm a',
                          ).format(news.date);
                          return NewsCard(
                            news: news,
                            button: () {},
                            date: formattedDate,
                            time: formattedTime,
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
                    onTap: () {
                      context.pushNamed(RouteConstants.staffLeaveRequestHome);
                      Navigator.pop(context);
                    },
                  ),
                  Divider(height: 0, color: Color(0xFFE6E6E6)),
                  _OptionTile(
                    icon: Icons.menu_book_outlined,
                    label: 'Students',
                    onTap: () {
                      context.pushNamed(RouteConstants.studentListing);
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
