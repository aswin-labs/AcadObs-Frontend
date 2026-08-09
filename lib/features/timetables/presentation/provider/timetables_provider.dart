import 'package:acadobs/features/timetables/data/models/day_timetable_model.dart';
import 'package:acadobs/features/timetables/data/models/timetable_model.dart';
import 'package:acadobs/features/timetables/data/models/timetable_substitution_model.dart';
import 'package:acadobs/features/timetables/data/models/timetable_type.dart';
import 'package:acadobs/features/timetables/data/services/timetable_services.dart';
import 'package:flutter/material.dart';

class TimetablesProvider extends ChangeNotifier {
  final TimetableServices _timetableServices = TimetableServices();

  bool _isLoadingToday = false;
  bool get isLoadingToday => _isLoadingToday;

  List<TimetableModel> _todayTimetable = [];
  List<TimetableModel> get todayTimetable => _todayTimetable;

  List<TimetableSubstitutionModel> _todaySubstitutions = [];
  List<TimetableSubstitutionModel> get todaySubstitutions =>
      _todaySubstitutions;

  int? _today;
  int? get today => _today;

  String? _todayError;
  String? get todayError => _todayError;
  bool _isTodayFetchedOnce = false;
  TimetableType? _lastTodayTimetableType;
  int? _lastTodayStudentId;
  bool _isLoadingAllDays = false;
  bool get isLoadingAllDays => _isLoadingAllDays;

  bool _isAllDaysFetchedOnce = false;

  List<DayTimetableModel> _allDayTimetable = [];
  List<DayTimetableModel> get allDayTimetable => _allDayTimetable;

  String? _allDayError;
  String? get allDayError => _allDayError;

  // fetch today timetable
  Future<void> fetchTodayTimetable({
    required TimetableType type,
    int? studentId,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingToday) return;

    final isSameRequest =
        _lastTodayTimetableType == type && _lastTodayStudentId == studentId;

    if (_isTodayFetchedOnce && isSameRequest && !forceRefresh) {
      return;
    }

    _isLoadingToday = true;
    _todayError = null;

    // Remove previously loaded timetable when changing type.
    if (!isSameRequest) {
      _today = null;
      _todayTimetable = [];
      _todaySubstitutions = [];
    }

    notifyListeners();

    try {
      final response = await _timetableServices.fetchTodayTimetable(
        type: type,
        studentId: studentId,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch timetable: ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>;

      _today = data['today'];

      _todayTimetable =
          (data['timetable'] as List? ?? [])
              .map(
                (item) =>
                    TimetableModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList();

      _todaySubstitutions =
          (data['substitutions'] as List? ?? [])
              .map(
                (item) => TimetableSubstitutionModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();

      _lastTodayTimetableType = type;
      _lastTodayStudentId = studentId;
      _isTodayFetchedOnce = true;
    } catch (e) {
      _todayError = e.toString();
      _todayTimetable = [];
      _todaySubstitutions = [];

      debugPrint('Fetch today timetable error: $e');
    } finally {
      _isLoadingToday = false;
      notifyListeners();
    }
  }

  // fetch all days timetable
  Future<void> fetchAllDayTimetable({
    required TimetableType type,
    int? studentId,
    bool forceRefresh = false,
  }) async {
    if (_isLoadingAllDays) return;
    if (_isAllDaysFetchedOnce && !forceRefresh) return;

    _isLoadingAllDays = true;
    _allDayError = null;
    notifyListeners();

    try {
      final response = await _timetableServices.fetchAllDayTimetable(
        type: type,
        studentId: studentId,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch timetable: ${response.statusCode}');
      }

      final data = response.data as Map<String, dynamic>;
      final timetableData = data['timetable'] as List? ?? [];

      _allDayTimetable =
          type == TimetableType.teacher
              ? _groupTeacherTimetableByDay(timetableData)
              : timetableData
                  .map(
                    (item) => DayTimetableModel.fromJson(
                      Map<String, dynamic>.from(item),
                    ),
                  )
                  .toList();

      _allDayTimetable.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

      _isAllDaysFetchedOnce = true;
    } catch (e) {
      _allDayTimetable = [];
      _allDayError = e.toString();

      debugPrint('Fetch all-day timetable error: $e');
    } finally {
      _isLoadingAllDays = false;
      notifyListeners();
    }
  }

  // grouped timetable helper
  List<DayTimetableModel> _groupTeacherTimetableByDay(
    List<dynamic> timetableData,
  ) {
    final Map<int, List<TimetableModel>> groupedTimetable = {};

    for (final item in timetableData) {
      final timetable = TimetableModel.fromJson(
        Map<String, dynamic>.from(item),
      );

      final day = timetable.dayOfWeek;

      if (day == null) continue;

      groupedTimetable.putIfAbsent(day, () => []);
      groupedTimetable[day]!.add(timetable);
    }

    return groupedTimetable.entries.map((entry) {
      entry.value.sort(
        (a, b) => (a.periodNumber ?? 0).compareTo(b.periodNumber ?? 0),
      );

      return DayTimetableModel(dayOfWeek: entry.key, periods: entry.value);
    }).toList();
  }

  // clear today timetable
  void clearTodayTimetable() {
    _today = null;
    _todayTimetable = [];
    _todaySubstitutions = [];
    _todayError = null;
    _isTodayFetchedOnce = false;
    _lastTodayTimetableType = null;
    _lastTodayStudentId = null;

    notifyListeners();
  }
}
