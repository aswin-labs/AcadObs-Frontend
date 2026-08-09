import 'package:acadobs/features/timetables/data/models/timetable_type.dart';
import 'package:acadobs/features/timetables/presentation/provider/timetables_provider.dart';
import 'package:acadobs/routes/modules/common_routes.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class TeacherTodayTimetableWidget extends StatefulWidget {
  const TeacherTodayTimetableWidget({super.key});

  @override
  State<TeacherTodayTimetableWidget> createState() =>
      _TeacherTodayTimetableWidgetState();
}

class _TeacherTodayTimetableWidgetState
    extends State<TeacherTodayTimetableWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TimetablesProvider>().fetchTodayTimetable(
        type: TimetableType.teacher,
      );
    });
  }

  Future<void> _refresh() {
    return context.read<TimetablesProvider>().fetchTodayTimetable(
      type: TimetableType.teacher,
      forceRefresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimetablesProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Today's Timetable",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.pushNamed(
                        RouteConstants.allDayTimetableScreen,
                        extra: TodayTimetableParameters(
                          timetableType: TimetableType.teacher,
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text(
                      'View Weekly',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: provider.isLoadingToday ? null : _refresh,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              if (provider.isLoadingToday)
                const SizedBox(
                  height: 90,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (provider.todayError != null)
                SizedBox(
                  height: 90,
                  child: Center(
                    child: TextButton(
                      onPressed: _refresh,
                      child: const Text('Retry timetable'),
                    ),
                  ),
                )
              else if (provider.todayTimetable.isEmpty &&
                  provider.todaySubstitutions.isEmpty)
                SizedBox(
                  height: 90,
                  child: Center(
                    child: Text(
                      'No timetable available for today',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.todaySubstitutions.isNotEmpty) ...[
                      const Text(
                        'Substitutions',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(221, 74, 73, 73),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: provider.todaySubstitutions.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final item = provider.todaySubstitutions[index];

                            return _SmallTimetableBox(
                              periodNumber: item.timetable?.periodNumber ?? 0,
                              title:
                                  item.timetable?.classGrade?.classname ??
                                  'Class not assigned',
                              description:
                                  item.subject?.subjectName ??
                                  'Subject not assigned',
                              isSubstitution: true,
                            );
                          },
                        ),
                      ),
                    ],

                    if (provider.todaySubstitutions.isNotEmpty &&
                        provider.todayTimetable.isNotEmpty)
                      const SizedBox(height: 16),

                    if (provider.todayTimetable.isNotEmpty) ...[
                      const Text(
                        'Timetable',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(221, 74, 73, 73),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 112,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: provider.todayTimetable.length,
                          separatorBuilder:
                              (_, __) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final item = provider.todayTimetable[index];

                            return _SmallTimetableBox(
                              periodNumber: item.periodNumber ?? 0,
                              title:
                                  item.classGrade?.classname ??
                                  'Class not assigned',
                              description:
                                  item.subject?.subjectName ??
                                  'Subject not assigned',
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SmallTimetableBox extends StatelessWidget {
  final int periodNumber;
  final String title;
  final String description;
  final bool isSubstitution;

  const _SmallTimetableBox({
    required this.periodNumber,
    required this.title,
    required this.description,
    this.isSubstitution = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isSubstitution ? const Color(0xFFD35400) : const Color(0xFFA86637);

    return Container(
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSubstitution ? const Color(0xFFFFF7F0) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isSubstitution
                  ? const Color(0xFFFFC48C)
                  : const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSubstitution
                          ? const Color(0xFFFFE5D0)
                          : const Color(0xFFFFECCE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$periodNumber',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (isSubstitution)
                Text(
                  'SUB',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 3),

          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
