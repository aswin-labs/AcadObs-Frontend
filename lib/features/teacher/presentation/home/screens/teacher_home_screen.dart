import 'dart:ui';

import 'package:acadobs/core/netwok/network_provider.dart';
import 'package:acadobs/core/netwok/screens/offline_banner.dart';
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
import 'package:acadobs/features/timetables/presentation/widgets/teacher_today_timetable_widget.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/class_grade_model.dart';
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
    ).scale(1.0).clamp(1.0, 1.6);

    final responsiveAppBarHeight = 175 * textScaleFactor;
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
                    backgroundColor: Colors.white,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Consumer<AuthProvider>(
                              builder: (context, provider, _) {
                                final bgImage =
                                    provider.schoolDetails?["bg_image"]
                                        ?.toString() ??
                                    '';

                                if (bgImage.isEmpty) {
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

                            ImageFiltered(
                              imageFilter: ImageFilter.blur(
                                sigmaX: 10,
                                sigmaY: 10,
                              ),
                              child: Container(
                                color: Colors.black.withAlpha(40),
                              ),
                            ),

                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF2196F3).withAlpha(180),
                                    const Color(0xFF1976D2).withAlpha(180),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),

                            SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  16,
                                  16,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Consumer<AuthProvider>(
                                            builder: (context, provider, _) {
                                              final schoolDetails =
                                                  provider.schoolDetails;

                                              final logo =
                                                  schoolDetails?["logo"]
                                                      ?.toString() ??
                                                  '';
                                              final schoolName =
                                                  schoolDetails?["name"]
                                                      ?.toString() ??
                                                  'School';

                                              return Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  if (logo.isNotEmpty) ...[
                                                    CircleAvatar(
                                                      radius: 16,
                                                      backgroundColor:
                                                          Colors.white,
                                                      child: ClipOval(
                                                        child: Image.network(
                                                          logo,
                                                          width: 32,
                                                          height: 32,
                                                          fit: BoxFit.cover,
                                                          errorBuilder: (
                                                            context,
                                                            error,
                                                            stackTrace,
                                                          ) {
                                                            return const Icon(
                                                              Icons.school,
                                                              size: 20,
                                                              color:
                                                                  Colors.grey,
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                  ],
                                                  Expanded(
                                                    child: Text(
                                                      capitalizeEachWord(
                                                        schoolName,
                                                      ),
                                                      maxLines: 3,
                                                      softWrap: true,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 8),

                                          Consumer<ProfileProvider>(
                                            builder: (context, provider, _) {
                                              if (provider.isLoading) {
                                                return Shimmer.fromColors(
                                                  baseColor: Colors.white
                                                      .withAlpha(120),
                                                  highlightColor: Colors.white
                                                      .withAlpha(220),
                                                  child: Container(
                                                    height: 32,
                                                    width: 160,
                                                    constraints:
                                                        const BoxConstraints(
                                                          maxWidth:
                                                              double.infinity,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              }

                                              return GestureDetector(
                                                onTap: refreshAllData,
                                                child: Text(
                                                  provider
                                                          .staffProfile
                                                          ?.user
                                                          ?.name ??
                                                      "",
                                                  maxLines: 3,
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),

                                          const SizedBox(height: 8),

                                          Text(
                                            DateFormat(
                                              'EEEE, dd MMMM',
                                            ).format(DateTime.now()),
                                            maxLines: 2,
                                            softWrap: true,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(
                                                200,
                                              ),
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

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
                          ],
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
                          widget.userType == UserType.teacher
                              ? Column(
                                children: [
                                  _buildSectionHeader("Quick Actions", null),
                                  const SizedBox(height: 12),
                                  buildQuickActions(context),

                                  // my class
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

                                      if (classData is! Map) {
                                        return const SizedBox.shrink();
                                      }

                                      final classId = classData["id"];
                                      final className =
                                          classData["classname"]?.toString() ??
                                          '';

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
                                                extra: ClassGradeModel(
                                                  id:
                                                      classId is int
                                                          ? classId
                                                          : int.parse(
                                                            classId.toString(),
                                                          ),
                                                  classname: className,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 24),

                                  TeacherTodayTimetableWidget(),

                                  // Today's Schedule Section
                                  // buildTimeTableSection(context),
                                  // buildSubstitutionSection(context),
                                  const SizedBox(height: 24),
                                ],
                              )
                              : SizedBox.shrink(),

                          // Updates Section
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
