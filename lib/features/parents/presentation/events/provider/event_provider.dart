import 'dart:developer';
import 'package:acadobs/features/parents/data/models/event_model.dart';
import 'package:acadobs/features/parents/data/services/event_services.dart';
import 'package:flutter/material.dart';

class EventProvider extends ChangeNotifier {
  final EventServices _eventServices = EventServices();
  List<Events> _events = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  List<Events> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  bool get hasMore => _hasMore;

  Future<void> fetchEvents({int pageNo = 1, bool isRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _eventServices.fetchEvents(pageNo: pageNo);
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
        //added remove duplication
        // Avoid adding duplicate events (based on unique id)
final existingIds = _events.map((e) => e.id).toSet(); // assuming each event has a unique id
final newEvents = fetched.where((e) => !existingIds.contains(e.id)).toList();

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
    }
    _isLoading = false;
    notifyListeners();
  }

  void loadMore() {
    if (_hasMore && !_isLoading) {
      fetchEvents(pageNo: _currentPage + 1);
    }
  }
}
