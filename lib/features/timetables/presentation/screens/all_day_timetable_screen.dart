import 'package:acadobs/core/utils/empty_screen.dart';
import 'package:acadobs/features/timetables/data/models/timetable_type.dart';
import 'package:acadobs/features/timetables/presentation/provider/timetables_provider.dart';
import 'package:acadobs/features/timetables/presentation/widgets/day_selector_widget.dart';
import 'package:acadobs/features/timetables/presentation/widgets/timetable_box.dart';
import 'package:acadobs/shared/widgets/common_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllDayTimetableScreen extends StatefulWidget {
  final TimetableType timetableType;
  final int? studentId;

  const AllDayTimetableScreen({
    super.key,
    required this.timetableType,
    this.studentId,
  });

  @override
  State<AllDayTimetableScreen> createState() => _AllDayTimetableScreenState();
}

class _AllDayTimetableScreenState extends State<AllDayTimetableScreen> {
  int? _selectedDay;

  final ScrollController _dayScrollController = ScrollController();

  @override
  void dispose() {
    _dayScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      await context.read<TimetablesProvider>().fetchAllDayTimetable(
        type: widget.timetableType,
        studentId: widget.studentId,
      );

      if (!mounted) return;

      _setInitialDay();
    });
  }

  void _setInitialDay() {
    final provider = context.read<TimetablesProvider>();

    if (provider.allDayTimetable.isEmpty) return;

    final today = DateTime.now().weekday;

    final selectedIndex = provider.allDayTimetable.indexWhere(
      (day) => day.dayOfWeek == today,
    );

    setState(() {
      _selectedDay =
          selectedIndex != -1
              ? today
              : provider.allDayTimetable.first.dayOfWeek;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_dayScrollController.hasClients) return;

      final index = selectedIndex != -1 ? selectedIndex : 0;

      _dayScrollController.animateTo(
        index * 95.0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'All Day Timetable', isBackButton: true),
      body: Consumer<TimetablesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingAllDays) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.allDayError != null) {
            return Center(child: Text(provider.allDayError!));
          }

          if (provider.allDayTimetable.isEmpty) {
            return Center(
              child: emptyScreen(message: "No timetable available for today."),
            );
          }

          final selectedDay = provider.allDayTimetable.firstWhere(
            (day) => day.dayOfWeek == _selectedDay,
            orElse: () => provider.allDayTimetable.first,
          );

          return RefreshIndicator(
            onRefresh: () async {
              await provider.fetchAllDayTimetable(
                type: widget.timetableType,
                studentId: widget.studentId,
                forceRefresh: true,
              );

              if (mounted) {
                _setInitialDay();
              }
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: DaySelector(
                    scrollController: _dayScrollController,
                    days: provider.allDayTimetable,
                    selectedDay: selectedDay.dayOfWeek,
                    onSelected: (day) {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                  ),
                ),

                if (selectedDay.periods.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('No periods for this day')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList.separated(
                      itemCount: selectedDay.periods.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final timetable = selectedDay.periods[index];

                        final isTeacher =
                            widget.timetableType == TimetableType.teacher;

                        return TimetableBox(
                          periodNumber: timetable.periodNumber ?? 0,
                          title:
                              isTeacher
                                  ? timetable.classGrade?.classname ??
                                      'Class not assigned'
                                  : timetable.user?.name ??
                                      'Teacher not assigned',
                          description:
                              timetable.subject?.subjectName ??
                              'Subject not assigned',
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
