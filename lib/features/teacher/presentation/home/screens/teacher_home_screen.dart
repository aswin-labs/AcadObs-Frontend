import 'package:acadobs/core/netwok/network_provider.dart';
import 'package:acadobs/core/utils/helpers/capitalize_word.dart';
import 'package:acadobs/features/achievements/presentaion/provider/achievement_provider.dart';
import 'package:acadobs/features/authentication/data/models/user_type_enum.dart';
import 'package:acadobs/features/authentication/presentation/provider/auth_provider.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/notices/presentation/provider/notice_provider.dart';
import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/profile/presentation/provider/profile_provider.dart';
import 'package:acadobs/features/teacher/presentation/home/provider/teacher_attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/award_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/build_quick_actions.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/check_in_widget.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/event_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/fab_option_dialog.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/news_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/notice_section.dart';
import 'package:acadobs/features/teacher/presentation/home/widgets/quick_action_card.dart';
import 'package:acadobs/features/timetables/data/models/timetable_type.dart';
import 'package:acadobs/features/timetables/presentation/widgets/today_timetable_widget.dart';
import 'package:acadobs/routes/modules/staff_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/widgets/centered_offline_view.dart';
import 'package:acadobs/shared/widgets/common_floating_button.dart';
import 'package:acadobs/shared/widgets/double_back_to_exit.dart';
import 'package:acadobs/shared/widgets/profile_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class TeacherHomeScreen extends StatefulWidget {
  final UserType userType;
  const TeacherHomeScreen({super.key, required this.userType});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  late EventProvider eventProvider;
  late NoticeProvider noticeProvider;
  late NewsProvider newsProvider;
  late StudentLeaveRequestProvider studentLeaveRequestProvider;
  late TeacherAttendanceProvider teacherAttendanceProvider;
  late AchievementProvider achievementProvider;
  late ProfileProvider profileProvider;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    eventProvider = context.read<EventProvider>();
    noticeProvider = context.read<NoticeProvider>();
    newsProvider = context.read<NewsProvider>();
    studentLeaveRequestProvider = context.read<StudentLeaveRequestProvider>();
    teacherAttendanceProvider = context.read<TeacherAttendanceProvider>();
    achievementProvider = context.read<AchievementProvider>();
    profileProvider = context.read<ProfileProvider>();
    authProvider = context.read<AuthProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        refreshAllData();
      }
    });
  }

  bool _isRefreshing = false;

  List<Future<dynamic>> _getRefreshTasks() {
    final commonTasks = <Future<dynamic>>[
      authProvider.fetchSchoolDetailsForTeacher(),
      eventProvider.fetchLatestEvents(forStaff: true),
      noticeProvider.fetchLatestNotices(),
      teacherAttendanceProvider.getTodayAttendanceStatus(),
      achievementProvider.fetchLatestSchoolAchievements(forStaff: true),
      profileProvider.fetchProfileStaff(),
      newsProvider.fetchLatestNews(limit: 3, forStaff: true),
    ];

    switch (widget.userType) {
      case UserType.teacher:
        return [
          ...commonTasks,
          studentLeaveRequestProvider.getLeaveRequestNotification(),
        ];

      case UserType.nonTeachingStaff:
        return commonTasks;

      default:
        return [];
    }
  }

  Future<void> refreshAllData() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    try {
      final tasks = _getRefreshTasks();

      if (tasks.isNotEmpty) {
        await Future.wait(tasks);
      }
    } catch (error, stackTrace) {
      debugPrint('${widget.userType.name} home refresh error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkProvider = context.watch<NetworkProvider>();
    final textScaleFactor = MediaQuery.textScalerOf(
      context,
    ).scale(1.0).clamp(1.0, 1.4);

    final responsiveAppBarHeight = (180 * textScaleFactor).clamp(175.0, 225.0);

    if (!networkProvider.isConnected) {
      return DoubleBackToExit(
        child: Scaffold(
          backgroundColor: Colors.grey[50],
          body: CenteredOfflineView(onRetry: () => refreshAllData()),
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
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: responsiveAppBarHeight,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: const Color(0xFF00AEF0),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Consumer<AuthProvider>(
                            builder: (context, authProv, _) {
                              final schoolDetails = authProv.schoolDetails;
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
                                        child: Consumer<AuthProvider>(
                                          builder: (
                                            context,
                                            authProv,
                                            _,
                                          ) {
                                            final schoolDetails =
                                                authProv.schoolDetails;
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
                                                    .staffProfile
                                                    ?.user
                                                    ?.dp,
                                            ontap: () {
                                              context.pushNamed(
                                                RouteConstants.profileScreen,
                                                extra: true,
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  const Spacer(),

                                  // Bottom Row: Greeting & Staff Name
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
                                              .staffProfile
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
                                          GestureDetector(
                                            onTap: refreshAllData,
                                            child: Text(
                                              name.isNotEmpty
                                                  ? capitalizeEachWord(name)
                                                  : "Hi, Teacher",
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
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            DateFormat(
                                              'EEEE, dd MMMM',
                                            ).format(DateTime.now()),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white.withAlpha(
                                                200,
                                              ),
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

                  // Main Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Check-in Card
                          CheckInWidget(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  context.pushNamed(
                                    RouteConstants.staffAttendanceHistoryScreen,
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    "View Check-in History",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      decoration: TextDecoration.underline,
                                      decorationColor: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Quick Actions Section
                          widget.userType == UserType.teacher
                              ? Column(
                                children: [
                                  _buildSectionHeader("Quick Actions", null),
                                  const SizedBox(height: 12),
                                  buildQuickActions(context),

                                  // my class details section
                                  Consumer2<
                                    AuthProvider,
                                    StudentLeaveRequestProvider
                                  >(
                                    builder: (
                                      context,
                                      authProvider,
                                      leaveProvider,
                                      _,
                                    ) {
                                      final classData =
                                          authProvider.schoolDetails?["Class"];
                                      final leaveNotificationCount =
                                          leaveProvider.leaveNotificationCount;
                                      final isCbse =
                                          (authProvider
                                                  .schoolDetails?["Syllabus"]["name"] ==
                                              "CBSE");

                                      if (classData is! Map) {
                                        return const SizedBox.shrink();
                                      }

                                      final classId = classData["id"];
                                      final className =
                                          classData["classname"]?.toString() ??
                                          '';
                                      final classYear = classData["year"];

                                      final classGrade = ClassGradeModel(
                                        id:
                                            classId is int
                                                ? classId
                                                : int.parse(classId.toString()),
                                        classname: className,
                                        year: classYear,
                                      );

                                      if (classId == null ||
                                          className.isEmpty) {
                                        return const SizedBox.shrink();
                                      }

                                      return Column(
                                        children: [
                                          const SizedBox(height: 10),
                                          QuickActionCard(
                                            icon: LucideIcons.school,
                                            label: "My Class Details",
                                            notificationCount:
                                                leaveNotificationCount,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF7B61FF),
                                                Color(0xFF5B42F3),
                                              ],
                                            ),
                                            onTap: () {
                                              context.pushNamed(
                                                RouteConstants.myClassesScreen,
                                                extra: MyClassesRouteArgs(
                                                  classGrade: classGrade,
                                                  isCbse: isCbse,
                                                ),
                                                //  ClassGradeModel(
                                                // id:
                                                //     classId is int
                                                //         ? classId
                                                //         : int.parse(
                                                //           classId.toString(),
                                                //         ),
                                                // classname: className,
                                                // ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  // timetable section
                                  TodayTimetableWidget(
                                    type: TimetableType.teacher,
                                  ),
                                  const SizedBox(height: 24),
                                ],
                              )
                              : SizedBox.shrink(),

                          // Updates Section
                          Consumer3<
                            NoticeProvider,
                            EventProvider,
                            NewsProvider
                          >(
                            builder: (
                              context,
                              noticeProv,
                              eventProv,
                              newsProv,
                              _,
                            ) {
                              final hasNotices =
                                  noticeProv.isLatestLoading ||
                                  noticeProv.noticesLatest.isNotEmpty;
                              final hasEvents =
                                  eventProv.isLatestLoading ||
                                  eventProv.eventsLatest.isNotEmpty;
                              final hasNews =
                                  newsProv.isLatestLoading ||
                                  newsProv.newsLatest.isNotEmpty;

                              if (!hasNotices && !hasEvents && !hasNews) {
                                return const SizedBox.shrink();
                              }
                              return _buildSectionHeader("Updates", null);
                            },
                          ),
                          // Latest Notices
                          const NoticeSection(),
                          // Latest Events
                          const EventSection(),
                          // Latest News
                          const NewsSection(),
                          // Awards and Accomplishments
                          const AwardSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton:
            widget.userType == UserType.teacher
                ? CommonFloatingButton(
                  onPressed:
                      () => showDialog(
                        context: context,
                        builder: (context) => FabOptionsDialog(),
                      ),
                )
                : null,
      ),
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
