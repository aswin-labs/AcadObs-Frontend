import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/features/events/data/models/event_model.dart';
import 'package:acadobs/features/events/data/services/event_services.dart';
import 'package:flutter/material.dart';

class EventProvider extends ChangeNotifier {
  // ===========================================================================
  // COMMON STATE
  // ===========================================================================
  String? _error;
  String? get error => _error;

  void clearError() => _error = null;

  // ===========================================================================
  // LOADING STATES
  // ===========================================================================
  bool _isLoading = false; // For all events (paginated)
  bool get isLoading => _isLoading;

  bool _isLatestLoading = false; // For latest events (home)
  bool get isLatestLoading => _isLatestLoading;

  // ===========================================================================
  // PAGINATED EVENTS (ALL)
  // ===========================================================================
  final List<EventModel> _eventsAll = [];
  List<EventModel> get eventsAll => List.unmodifiable(_eventsAll);

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  Future<void> fetchEvents({
    required bool forStaff,
    bool loadMore = false,
    bool forceRefresh = false,
    int limit = AppConstants.paginationLimit, // Default = 13
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    try {
      // Reset when not loading more or forcing refresh
      if (!loadMore || forceRefresh) {
        _currentPage = 1;
        _eventsAll.clear();
      }

      final response = await EventServices().fetchEvents(
        forStaff: forStaff,
        pageNo: _currentPage,
        limit: limit,
      );

      if (response.statusCode == 200) {
        log("Events listing:${response.data.toString()}");
        final data = response.data;
        _totalPages = data['totalPages'] ?? 1;
        _currentPage = data['currentPage'] ?? 1;

        final fetched =
            (data['events'] as List)
                .map((e) => EventModel.fromJson(e))
                .toList();

        _eventsAll.addAll(fetched);

        if (_currentPage < _totalPages) {
          _currentPage++;
        }
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching events: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // LATEST EVENTS (HOME)
  // ===========================================================================
  final List<EventModel> _eventsLatest = [];
  List<EventModel> get eventsLatest => List.unmodifiable(_eventsLatest);

  Future<void> fetchLatestEvents({
    required bool forStaff,
    int limit = 3,
  }) async {
    if (_isLatestLoading) return;
    _isLatestLoading = true;
    notifyListeners();

    try {
      _eventsLatest.clear();

      final response = await EventServices().fetchEvents(
        forStaff: forStaff,
        pageNo: 1,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final fetched =
            (data['events'] as List)
                .map((e) => EventModel.fromJson(e))
                .toList();

        _eventsLatest.addAll(fetched);
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching latest events: $_error");
    } finally {
      _isLatestLoading = false;
      notifyListeners();
    }
  }
}
