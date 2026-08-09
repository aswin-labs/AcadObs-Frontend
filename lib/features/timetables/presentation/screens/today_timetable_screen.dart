import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/timetables/data/models/timetable_type.dart';
import 'package:acadobs/features/timetables/presentation/provider/timetables_provider.dart';
import 'package:acadobs/features/timetables/presentation/widgets/timetable_box.dart';
import 'package:acadobs/routes/modules/common_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TodayTimetableScreen extends StatefulWidget {
  final TimetableType timetableType;
  final int? studentId;

  const TodayTimetableScreen({
    super.key,
    required this.timetableType,
    this.studentId,
  });

  @override
  State<TodayTimetableScreen> createState() => _TodayTimetableScreenState();
}

class _TodayTimetableScreenState extends State<TodayTimetableScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TimetablesProvider>().fetchTodayTimetable(
        type: widget.timetableType,
        studentId: widget.studentId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Timetable', isBackButton: true),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<TimetablesProvider>().fetchTodayTimetable(
            type: widget.timetableType,
            studentId: widget.studentId,
            forceRefresh: true,
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
              sliver: SliverToBoxAdapter(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      RouteConstants.allDayTimetableScreen,
                      extra: TodayTimetableParameters(
                        timetableType: widget.timetableType,
                        studentId: widget.studentId?.toString(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    "View Weekly Timetable",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            Consumer<TimetablesProvider>(
              builder: (context, provider, _) {
                if (provider.isLoadingToday) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (provider.todayError != null) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text(provider.todayError!)),
                  );
                }

                if (provider.todayTimetable.isEmpty &&
                    provider.todaySubstitutions.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: emptyScreen(
                        message: "No timetable available for today.",
                      ),
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: [
                    if (provider.todaySubstitutions.isNotEmpty) ...[
                      const SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 14, 16, 12),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            'Today\'s Substitutions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final substitution =
                                provider.todaySubstitutions[index];

                            return TimetableBox(
                              periodNumber:
                                  substitution.timetable?.periodNumber ?? 0,
                              title:
                                  substitution.subject?.subjectName ??
                                  'Subject not assigned',
                              description:
                                  substitution.user?.name ??
                                  'Teacher not assigned',
                              isSubstitution: true,
                            );
                          }, childCount: provider.todaySubstitutions.length),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 72,
                              ),
                        ),
                      ),
                    ],
                    if (provider.todayTimetable.isNotEmpty) ...[
                      const SliverPadding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            "Today's Timetable",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final timetable = provider.todayTimetable[index];

                            final isTeacher =
                                widget.timetableType == TimetableType.teacher;

                            return TimetableBox(
                              periodNumber: timetable.periodNumber ?? 0,
                              title:
                                  timetable.subject?.subjectName ??
                                  'Subject not assigned',
                              description:
                                  isTeacher
                                      ? timetable.classGrade?.classname ??
                                          'Class not assigned'
                                      : timetable.user?.name ??
                                          'Teacher not assigned',
                            );
                          }, childCount: provider.todayTimetable.length),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                mainAxisExtent: 72,
                              ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
