import 'dart:developer';

import 'package:acadobs/features/parents/data/models/event_model.dart';
import 'package:acadobs/features/parents/data/services/event_services.dart';
import 'package:flutter/material.dart';

class EventProvider extends ChangeNotifier {
  final EventServices _eventServices = EventServices();
  List<Events> _events = [];
  final List<Events> _latestEvent = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Events> get events => _events;
  List<Events> get latestEvent => _latestEvent;

  //distinguishing today event
  List<Events> get todayEvents =>
      _events.where((e) {
          if (e.createdAt == null) return false;
          final now = DateTime.now();
          return now.year == e.createdAt!.year &&
              now.month == e.createdAt!.month &&
              now.day == e.createdAt!.day;
        }).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );

  //distinguishing yesterday event
  List<Events> get yesterdayEvents =>
      _events.where((e) {
          if (e.createdAt == null) return false;
          final now = DateTime.now();
          final yesterday = now.subtract(Duration(days: 1));
          return yesterday.year == e.createdAt!.year &&
              yesterday.month == e.createdAt!.month &&
              yesterday.day == e.createdAt!.day;
        }).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );

  //earlier events
  List<Events> get earlierEvents =>
      _events.where((e) {
          if (e.createdAt == null) return false;
          final now = DateTime.now();
          // final yesterday = now.subtract(Duration(days: 1));
          final todayMidnight = DateTime(now.year, now.month, now.day);
          return e.createdAt!.isBefore(
            todayMidnight.subtract(const Duration(days: 1)),
          );
        }).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  Future<void> fetchLatestEvents({
    int pageNo = 1,
    bool isRefresh = false,
    int limit = 3,
  }) async {
    if (_isLoading && !isRefresh) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _eventServices.fetchLatestEvents(
        pageNo: pageNo,
        limit: limit,
      );
      log('Event API response: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data['events'];
        final totalPages = response.data['totalPages'];

        if (pageNo > totalPages) {
          _hasMore = false;
          _isLoading = false;
          notifyListeners();
          return;
        }
        final fetched = List<Events>.from(data.map((e) => Events.fromJson(e)));

        // Avoid adding duplicate events (based on unique id)
        final existingIds =
            _events
                .map((e) => e.id)
                .toSet(); // assuming each event has a unique id
        final newEvents =
            fetched.where((e) => !existingIds.contains(e.id)).toList();

        fetched.sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );

        if (isRefresh) {
          _events = fetched;
          _currentPage = 1;
        } else {
          // _events.addAll(fetched);
          _events.addAll(newEvents);

          _currentPage = pageNo;
        }
        _hasMore = _currentPage < totalPages;
      } else {
        _error = 'Failed to fetch events ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHomeLatestEvents({int limit = 3}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _eventServices.fetchLatestEvents(
        pageNo: 1,
        limit: limit,
      );
      if (response.statusCode == 200) {
        final data = response.data['events'];
        final fetched = List<Events>.from(data.map((e) => Events.fromJson(e)));
        fetched.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

        _latestEvent
          ..clear()
          ..addAll(fetched.take(limit));
        notifyListeners();
      } else {
        log("Failed to fetch latest home notices: ${response.statusCode}");
      }
    } catch (e) {
      log("Error in fetchHomeLatestNotices: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void loadMore() {
    if (_hasMore && !_isLoading) {
      fetchLatestEvents(pageNo: _currentPage + 1);
    }
  }
}
