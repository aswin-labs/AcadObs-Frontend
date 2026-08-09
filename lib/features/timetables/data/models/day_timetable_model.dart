import 'package:acadobs/features/timetables/data/models/timetable_model.dart';

class DayTimetableModel {
  final int dayOfWeek;
  final List<TimetableModel> periods;

  const DayTimetableModel({
    required this.dayOfWeek,
    required this.periods,
  });

  factory DayTimetableModel.fromJson(Map<String, dynamic> json) {
    return DayTimetableModel(
      dayOfWeek: json['day_of_week'] as int,
      periods:
          (json['periods'] as List? ?? [])
              .map(
                (item) => TimetableModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(),
    );
  }
}