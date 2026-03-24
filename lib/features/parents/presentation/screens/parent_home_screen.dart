import 'package:acadobs/core/netwok/network_provider.dart';
import 'package:acadobs/core/netwok/screens/offline_banner.dart';
import 'package:acadobs/core/utils/urls/base_urls.dart';
import 'package:acadobs/core/utils/urls/media_end_points.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/features/authentication/presentation/provider/auth_provider.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/parents/presentation/provider/parent_provider.dart';
import 'package:acadobs/features/parents/presentation/widgets/latest_award_section.dart';
import 'package:acadobs/features/parents/presentation/widgets/latest_events_section.dart';
import 'package:acadobs/features/parents/presentation/widgets/latest_news_section.dart';
import 'package:acadobs/features/parents/presentation/widgets/my_children_section.dart';
import 'package:acadobs/features/tracking/presentation/provider/student_route_provider.dart';
import 'package:acadobs/features/tracking/presentation/widgets/bus_route_section.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/profile_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
      context.read<AchievementProvider>().fetchLatestSchoolAchievements(
        forStaff: false,
      ),
      context.read<StudentRouteProvider>().getStudentRoutes(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // final schoolName = context.watch<ParentProvider>().schoolName;
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
                              Consumer<AuthProvider>(
                                builder: (context, provider, _) {
                                  return Row(
                                    children: [
                                      // Icon(Icons.school, size: 35),
                                      Image.network(
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return const Icon(
                                            Icons.school,
                                            size: 35,
                                          );
                                        },
                                        width: 30,
                                        height: 30,
                                        "${BaseUrls.media}${MediaEndpoints.logo}${provider.logo}",
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          provider.schoolName ?? "",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            // color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
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
                      MyChildrenSection(),
                      // Bus route section
                      Consumer<StudentRouteProvider>(
                        builder: (context, provider, _) {
                          final studentRoutes = provider.studentRoutes;

                          bool hasRoutes =
                              studentRoutes.isNotEmpty &&
                              (studentRoutes[0].routes?.isNotEmpty ?? false);

                          if (provider.isLoading) {
                            return BusRouteSection();
                          }

                          if (!hasRoutes) {
                            return SizedBox();
                          }
                          return BusRouteSection();
                        },
                      ),
                      // Latest Events Section
                      LatestEventsSection(),

                      // Latest News Section
                      LatestNewsSection(),

                      SizedBox(height: 15),
                      // latest Award section
                      LatestAwardSection(),
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
