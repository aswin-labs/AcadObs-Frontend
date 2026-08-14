import 'package:acadobs/core/netwok/network_provider.dart';
import 'package:acadobs/core/netwok/screens/offline_banner.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
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
import 'package:acadobs/shared/widgets/double_back_to_exit.dart';
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
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    parentProvider = context.read<ParentProvider>();
    authProvider = context.read<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      refreshAllData();
    });
  }

  Future<void> refreshAllData({bool forceRefresh = false}) async {
    await Future.wait([
      authProvider.fetchSchoolDetailsForGuardianBySchoolId(),
      parentProvider.fetchStudentsUnderParentBySchoolId(
        forceRefresh: forceRefresh,
      ),
      context.read<EventProvider>().fetchLatestEvents(
        limit: 3,
        forStaff: false,
      ),
      context.read<NewsProvider>().fetchLatestNews(limit: 3, forStaff: false),
      context.read<AchievementProvider>().fetchLatestSchoolAchievements(
        forStaff: false,
      ),
      context.read<StudentRouteProvider>().getStudentRoutes(),
      parentProvider.fetchSchoolDetailsForParent(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();

    return DoubleBackToExit(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Stack(
          children: [
            RefreshIndicator(
              onRefresh: refreshAllData,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 180,
                    pinned: true,
                    floating: false,
                    automaticallyImplyLeading: false,
                    backgroundColor: const Color(0xFF00AEF0),
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
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Consumer2<AuthProvider, ParentProvider>(
                            builder: (context, authProv, parentProv, _) {
                              final schoolDetails =
                                  authProv.schoolDetails ??
                                  parentProv.schoolDetails;
                              final bgImage = schoolDetails?['bg_image'];

                              if (bgImage == null ||
                                  bgImage.toString().trim().isEmpty) {
                                return Image.asset(
                                  'assets/school.jpg',
                                  fit: BoxFit.cover,
                                );
                              }

                              return Image.network(
                                bgImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/school.jpg',
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            },
                          ),

                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xE635C2C1), Color(0xE600AEF0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),

                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                20,
                                20,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Consumer2<AuthProvider, ParentProvider>(
                                    builder: (
                                      context,
                                      authProv,
                                      parentProv,
                                      _,
                                    ) {
                                      final schoolDetails =
                                          authProv.schoolDetails ??
                                          parentProv.schoolDetails;
                                      return Row(
                                        children: [
                                          if (schoolDetails?['logo'] != null)
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.white,
                                              child: ClipOval(
                                                child: Image.network(
                                                  schoolDetails!['logo'],
                                                  width: 32,
                                                  height: 32,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) {
                                                    return const Icon(
                                                      Icons.business_outlined,
                                                      color: Colors.grey,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          const SizedBox(width: 8),
                                          Text(
                                            capitalizeEachWord(
                                              schoolDetails?['name'] ?? '',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 8),

                                  Text(
                                    "Hi, Parent",
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
      ),
    );
  }
}
