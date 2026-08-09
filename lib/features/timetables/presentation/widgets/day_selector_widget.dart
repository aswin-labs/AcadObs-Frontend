import 'package:acadobs/features/timetables/data/models/day_timetable_model.dart';
import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final List<DayTimetableModel> days;
  final int selectedDay;
  final ValueChanged<int> onSelected;
  final ScrollController scrollController;

  const DaySelector({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.onSelected,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index].dayOfWeek;
          final isSelected = day == selectedDay;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onSelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? Theme.of(context).primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                ),
                boxShadow:
                    isSelected
                        ? [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                        : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 7),
                  ],
                  Text(
                    _dayName(day),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _dayName(int day) {
    return switch (day) {
      DateTime.monday => 'Monday',
      DateTime.tuesday => 'Tuesday',
      DateTime.wednesday => 'Wednesday',
      DateTime.thursday => 'Thursday',
      DateTime.friday => 'Friday',
      DateTime.saturday => 'Saturday',
      DateTime.sunday => 'Sunday',
      _ => 'Day $day',
    };
  }
}
