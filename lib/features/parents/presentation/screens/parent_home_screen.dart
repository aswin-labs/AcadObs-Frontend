import 'package:acadobs/core/netwok/network_provider.dart';
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
import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:acadobs/features/tracking/presentation/provider/student_route_provider.dart';
import 'package:acadobs/features/tracking/presentation/widgets/bus_route_section.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/centered_offline_view.dart';
import 'package:acadobs/shared/widgets/double_back_to_exit.dart';
import 'package:acadobs/shared/widgets/profile_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({super.key});

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  late ParentProvider parentProvider;
  late AchievementProvider achievementProvider;
  late AuthProvider authProvider;
  late ProfileProvider profileProvider;

  @override
  void initState() {
    super.initState();
    parentProvider = context.read<ParentProvider>();
    authProvider = context.read<AuthProvider>();
    profileProvider = context.read<ProfileProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      refreshAllData();
    });
  }

  Future<void> refreshAllData({bool forceRefresh = true}) async {
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
      profileProvider.fetchProfileGuardian(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final textScaleFactor = MediaQuery.textScalerOf(
      context,
    ).scale(1.0).clamp(1.0, 1.4);
    final responsiveAppBarHeight = (170 * textScaleFactor).clamp(165.0, 215.0);

    if (!networkProvider.isConnected) {
      return DoubleBackToExit(
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: CenteredOfflineView(
            onRetry: () => refreshAllData(forceRefresh: true),
          ),
        ),
      );
    }

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
                    expandedHeight: responsiveAppBarHeight,
                    pinned: true,
                    floating: false,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: const Color(0xFF00AEF0),
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

                          // Subtle brand cyan/blue tint to maintain identity while showcasing the photo
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0x5935C2C1), // ~35% brand cyan
                                  Color(0x6600AEF0), // ~40% brand blue
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),

                          // Cinematic contrast vignette for status bar and high-contrast text legibility
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withAlpha(128),
                                  Colors.black.withAlpha(31),
                                  Colors.black.withAlpha(178),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),

                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                10,
                                16,
                                14,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: School Badge on the left, Profile on the right
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Consumer2<
                                          AuthProvider,
                                          ParentProvider
                                        >(
                                          builder: (
                                            context,
                                            authProv,
                                            parentProv,
                                            _,
                                          ) {
                                            final schoolDetails =
                                                authProv.schoolDetails ??
                                                parentProv.schoolDetails;
                                            final schoolName =
                                                schoolDetails?['name']
                                                    ?.toString() ??
                                                '';
                                            final logo =
                                                schoolDetails?['logo']
                                                    ?.toString() ??
                                                '';

                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withAlpha(
                                                  82,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(24),
                                                border: Border.all(
                                                  color: Colors.white.withAlpha(
                                                    64,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 13,
                                                    backgroundColor:
                                                        Colors.white,
                                                    child: ClipOval(
                                                      child:
                                                          logo.isNotEmpty
                                                              ? Image.network(
                                                                logo,
                                                                width: 26,
                                                                height: 26,
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                                errorBuilder:
                                                                    (
                                                                      context,
                                                                      error,
                                                                      stackTrace,
                                                                    ) => const Icon(
                                                                      Icons
                                                                          .school,
                                                                      size: 15,
                                                                      color: Color(
                                                                        0xFF00AEF0,
                                                                      ),
                                                                    ),
                                                              )
                                                              : const Icon(
                                                                Icons.school,
                                                                size: 15,
                                                                color: Color(
                                                                  0xFF00AEF0,
                                                                ),
                                                              ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      capitalizeEachWord(
                                                        schoolName.isNotEmpty
                                                            ? schoolName
                                                            : 'School',
                                                      ),
                                                      maxLines: 2,
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 13.5,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.white,
                                                        letterSpacing: 0.2,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Consumer<ProfileProvider>(
                                        builder: (context, profileProv, _) {
                                          return ProfileIcon(
                                            icon:
                                                CupertinoIcons.profile_circled,
                                            profileImageUrl:
                                                profileProv
                                                    .guardianProfile
                                                    ?.user
                                                    ?.dp,
                                            ontap:
                                                () => context.pushNamed(
                                                  RouteConstants.profileScreen,
                                                  extra: false,
                                                ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  // Bottom Row: Greeting & Guardian Name
                                  Consumer<ProfileProvider>(
                                    builder: (context, provider, _) {
                                      if (provider.isLoading) {
                                        return Shimmer.fromColors(
                                          baseColor: Colors.white.withAlpha(
                                            120,
                                          ),
                                          highlightColor: Colors.white
                                              .withAlpha(220),
                                          child: Container(
                                            height: 28,
                                            width: 150,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        );
                                      }

                                      final name =
                                          provider
                                              .guardianProfile
                                              ?.user
                                              ?.name ??
                                          '';

                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFF35C2C1),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                "WELCOME BACK",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white.withAlpha(
                                                    230,
                                                  ),
                                                  letterSpacing: 1.1,
                                                  shadows: const [
                                                    Shadow(
                                                      color: Colors.black54,
                                                      offset: Offset(0, 1),
                                                      blurRadius: 3,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            name.isNotEmpty
                                                ? capitalizeEachWord(name)
                                                : "Hi, Parent",
                                            maxLines: 2,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.2,
                                              height: 1.2,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black87,
                                                  offset: Offset(0, 1.5),
                                                  blurRadius: 5,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
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

                            bool hasRoutes = studentRoutes.isNotEmpty;

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
                        const LatestEventsSection(),

                        // Latest News Section
                        const LatestNewsSection(),

                        // latest Award section
                        const LatestAwardSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
