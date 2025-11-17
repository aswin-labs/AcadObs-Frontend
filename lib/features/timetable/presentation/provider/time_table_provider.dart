import 'dart:developer';

import 'package:acadobs/features/timetable/data/model/get_today_time_table.dart';
import 'package:acadobs/features/timetable/data/model/time_table_model.dart';
import 'package:acadobs/features/timetable/data/services/time_table_services.dart';
import 'package:flutter/material.dart';

class TimeTableProvider extends ChangeNotifier {
  final TimeTableServices _timeTableServices = TimeTableServices();

  final Map<int, List<TimeTableModel>> _timeTableByDay = {};
  Map<int, List<TimeTableModel>> get timeTableByDay => _timeTableByDay;

  final List<Substitution> _substitution = [];
  List<Substitution> get substitution => _substitution;

  // NEW: Support for GetTodayTimeTable model
  final List<GetTodayTimeTable> _allDayTimeTables = [];
  List<GetTodayTimeTable> get allDayTimeTables => _allDayTimeTables;

  /// Grouped timetable (new model): { dayOfWeek: [Period] }
  final Map<int, List<Period>> _timeTableByDays = {};
  Map<int, List<Period>> get timeTableByDays => _timeTableByDays;

  /// Today’s day number from API
  int? _today;
  int? get today => _today;

  /// Loading / error state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Flat list (optional, in case you still need it)
  final List<TimeTableModel> _timetable = [];
  List<TimeTableModel> get timetable => _timetable;
  final List<TimeTableModel> _timetableForStaff = [];

  List<TimeTableModel> get timetableForStaff => _timetableForStaff;

  /// Old API - fetch flat timetable
  Future<void> fetchTimeTable({int? studentId, bool forStaff = false}) async {
    _isLoading = true;
    _error = null;
    _timetable.clear();

    try {
      final response = await _timeTableServices.fetchTimeTable(
        studentId: studentId,
        forStaff: forStaff,
      );

      log("API Response: ${response.data}");
      log("API Response Status: ${response.statusCode}");
      log("API Response Data: ${response.data.toString()}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (forStaff) {
          if (data != null && data['timetable'] != null) {
            final List timetableJson = data['timetable'];
            log("Timetable JSON: $timetableJson");

            final List<TimeTableModel> fetchedTimetable =
                timetableJson
                    .map((item) => TimeTableModel.fromJson(item))
                    .toList();

            _timetableForStaff
              ..clear()
              ..addAll(fetchedTimetable);
          }
          //substitution
          if (data != null && data['substitutions'] != null) {
            final List substitutionsJson = data['substitutions'];
            log("substitutions JSON: $substitutionsJson");

            final List<Substitution> fetchedsubstitutions =
                substitutionsJson
                    .map((item) => Substitution.fromJson(item))
                    .toList();

            _substitution
              ..clear()
              ..addAll(fetchedsubstitutions);
          }
        }

        if (data != null && data['timetable'] != null) {
          final List timetableJson = data['timetable'];

          final List<TimeTableModel> fetchedTimetable =
              timetableJson
                  .map((item) => TimeTableModel.fromJson(item))
                  .toList();

          _timetable
            ..clear()
            ..addAll(fetchedTimetable);

          log("Fetched ${_timetable.length} timetable entries");
        } else {
          _error = "No timetable data found";
        }
      } else {
        _error = "Failed to fetch timetable (Status: ${response.statusCode})";
      }
    } catch (e) {
      log("Error fetching timetable: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh flat timetable
  Future<void> refreshTimeTable({int? studentId, bool forStaff = false}) async {
    _timetable.clear();
    await fetchTimeTable(studentId: studentId, forStaff: forStaff);
  }

  ////////

  Future<void> fetchAllDayTimeTableNew({
    int? studentId,
    bool forStaff = false,
  }) async {
    _isLoading = true;
    _error = null;
    try {
      final response = await _timeTableServices.getAllDayTimeTableByStudentId(
        studentId: studentId,
        forStaff: forStaff,
      );

      log("API Response (All Day): ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['timetable'] != null) {
          final List timetableJson = data['timetable'];

          _timeTableByDay.clear();

          for (var dayItem in timetableJson) {
            final int day = dayItem['day_of_week'];
            final List periods = dayItem['periods'];

            final List<Period> periodList =
                periods.map((p) => Period.fromJson(p)).toList();

            _timeTableByDays[day] = periodList;
          }

          log("Grouped timetable: $_timeTableByDay");
        } else {
          _error = "No timetable data found";
        }
      } else {
        _error = "Failed to fetch timetable (Status: ${response.statusCode})";
      }
    } catch (e) {
      log("Error fetching all-day timetable: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Period> getDayPeriods(int dayOfWeek) {
    return _timeTableByDays[dayOfWeek] ?? [];
  }

  // Fetch all day timetable for the teacher/staff
  Future<void> fetchAllDayTimeTableStaff({bool forStaff = true}) async {
    _isLoading = true;
    _error = null;
    try {
      final response = await _timeTableServices.getAllDayTimeTableByStudentId(
        forStaff: forStaff,
      );

      log("API Response (All Day): ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['timetable'] != null) {
          final List timetableJson = data['timetable'];

          // Clear the correct map
          _timeTableByDays.clear();

          for (var item in timetableJson) {
            final int day = item['day_of_week'] ?? 0;
            final period = Period.fromJson(item);

            // Use the same map everywhere
            _timeTableByDays.putIfAbsent(day, () => []).add(period);
          }

          log("Grouped timetable: $_timeTableByDays");
        } else {
          _error = "No timetable data found";
        }
      } else {
        _error = "Failed to fetch timetable (Status: ${response.statusCode})";
      }
    } catch (e) {
      log("Error fetching all-day timetable: $e");
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
