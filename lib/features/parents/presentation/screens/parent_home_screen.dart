import 'package:acadobs/core/netwok/network_provider.dart';
import 'package:acadobs/core/netwok/screens/offline_banner.dart';
import 'package:acadobs/core/utils/common_shimmer_list.dart';
import 'package:acadobs/core/utils/common_shimmer_tile.dart';
import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/core/utils/helpers/date_formatter.dart';
import 'package:acadobs/core/utils/helpers/time_formatter.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/events/presentation/widgets/event_card.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/news/presentation/widgets/news_card.dart';
import 'package:acadobs/features/notices/presentation/widgets/notice_card.dart';
import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/detail_screen_args.dart';
import 'package:acadobs/shared/widgets/profile_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  late ParentProvider parentProvider;
  late AchievementProvider achievementProvider;

  @override
  void initState() {
    super.initState();
    parentProvider = context.read<ParentProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      parentProvider.loadSchoolName();
      refreshAllData();
    });
  }

  Future<void> refreshAllData() async {
    await Future.wait([
      parentProvider.fetchStudentsUnderParentBySchoolId(),
      context.read<EventProvider>().fetchLatestEvents(
        limit: 3,
        forStaff: false,
      ),
      context.read<NewsProvider>().fetchLatestNews(limit: 3, forStaff: false),

      // context.read<AchievementProvider>().fetchSchoolAchievements(
      //   forStaff: false,
      //   limit: 3,
      // ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final schoolName = context.watch<ParentProvider>().schoolName;
    final networkProvider = context.watch<NetworkProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: refreshAllData,
            child: CustomScrollView(
              slivers: [
                // Modern App Bar with curved bottom
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  backgroundColor: Color(0xFF00AEF0),
                  automaticallyImplyLeading: false,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset("assets/school.jpg", fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xE635C2C1), Color(0xE600AEF0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 60,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (schoolName != null)
                                Text(
                                  schoolName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.white.withAlpha(203),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  refreshAllData();
                                },
                                child: Text(
                                  "Hi, Parent",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: ProfileIcon(
                        icon: CupertinoIcons.profile_circled,
                        ontap:
                            () => context.pushNamed(
                              RouteConstants.profileScreen,
                              extra: false,
                            ),
                      ),
                    ),
                  ],
                ),

                // Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // My Children Section
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.person_2_fill,
                                  color: Color(0xFF00AEF0),
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "My Children",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Consumer<ParentProvider>(
                              builder: (context, provider, _) {
                                if (provider.students.isEmpty) {
                                  return Container(
                                    padding: EdgeInsets.all(32),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(12),
                                          blurRadius: 10,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        "No students found",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: provider.students.length,
                                  separatorBuilder:
                                      (context, index) => SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final student = provider.students[index];
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withAlpha(12),
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap:
                                              () => context.pushNamed(
                                                RouteConstants.studentDetails,
                                                extra: StudentDetailParameters(
                                                  forStaff: false,
                                                  studentId: student.id,
                                                ),
                                              ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        Color(0xFF35C2C1),
                                                        Color(0xFF00AEF0),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    CupertinoIcons.person_fill,
                                                    color: Colors.white,
                                                    size: 24,
                                                  ),
                                                ),
                                                SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        student.fullName,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16,
                                                          color: Colors.black87,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4),
                                                      Text(
                                                        student
                                                                .classGrade
                                                                ?.classname ??
                                                            "No Class",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  CupertinoIcons.chevron_right,
                                                  color: Colors.grey[400],
                                                  size: 20,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Latest Events Section
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.calendar,
                                  color: Color(0xFF00AEF0),
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Latest Events",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Consumer<EventProvider>(
                              builder: (context, provider, _) {
                                if (provider.isLoading) {
                                  return commonShimmerList();
                                }

                                final events = provider.eventsLatest;
                                if (events.isEmpty) {
                                  return emptyScreen(
                                    message: "No Events Available",
                                  );
                                }

                                return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: events.length,
                                  separatorBuilder:
                                      (context, index) => SizedBox(height: 2),
                                  itemBuilder: (context, index) {
                                    final event = events[index];
                                    return EventCard(
                                      event: event,
                                      onViewTap:
                                          () => context.pushNamed(
                                            RouteConstants.eventlistdetails,
                                            extra: event,
                                          ),
                                      time: TimeFormatter.formatTime(
                                        event.createdAt ?? DateTime.now(),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // Latest News Section
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.news,
                                  color: Color(0xFF00AEF0),
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Latest News',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Consumer<NewsProvider>(
                              builder: (context, provider, _) {
                                if (provider.isLoading) {
                                  return commonShimmerList();
                                }

                                final news = provider.newsLatest;
                                if (news.isEmpty) {
                                  return emptyScreen(
                                    message: "No News Available",
                                  );
                                }

                                return ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: news.length,
                                  separatorBuilder:
                                      (context, index) => SizedBox(height: 2),
                                  itemBuilder: (context, index) {
                                    final newsItem = news[index];
                                    final formattedDate = DateFormat(
                                      'dd-MM-yy',
                                    ).format(newsItem.date);

                                    return NewsCard(
                                      news: newsItem,
                                      button: () {
                                        context.pushNamed(
                                          RouteConstants.newsScreen,
                                          extra: newsItem,
                                        );
                                      },
                                      date: formattedDate,
                                      time: TimeFormatter.formatTime(
                                        newsItem.createdAt,
                                      ),
                                      title: capitalizeEachWord(newsItem.title),
                                      content: newsItem.content,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 15),
                      Container(
                        margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.emoji_events,
                                  color: Color(0xFF00AEF0),
                                  size: 24,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Awards",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                                Spacer(),
                                TextButton(
                                  onPressed: () {
                                    context.pushNamed(
                                      RouteConstants.schoolAchievements,
                                      extra: false,
                                    );
                                  },
                                  child: Text('View'),
                                ),
                              ],
                            ),

                            Consumer<AchievementProvider>(
                              builder: (context, provider, _) {
                                final achievements =
                                    provider.schoolAchievementsLatest;
                                if (provider.isLoading) {
                                  return Center(child: CommonShimmerTile());
                                } else if (achievements.isEmpty) {
                                  return emptyScreen(
                                    message: "No Awards Available",
                                  );
                                }

                                return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: achievements.length,
                                  itemBuilder: (context, index) {
                                    final achievement = achievements[index];
                                    return NoticeCard(
                                      title: achievement.title ?? "",
                                      date: DateFormatter.formatDateTime(
                                        achievement.date ?? DateTime.now(),
                                      ),
                                      icon: Icons.workspace_premium,
                                      time: TimeFormatter.formatTime(
                                        achievement.createdAt ?? DateTime.now(),
                                      ),
                                      onTap: () {
                                        context.pushNamed(
                                          RouteConstants
                                              .achievementDetailsScreen,
                                          extra: DetailScreenArgs(
                                            id: achievement.id ?? 0,
                                            forStaff: false,
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!networkProvider.isConnected) OfflineBanner(),
        ],
      ),
    );
  }
}
