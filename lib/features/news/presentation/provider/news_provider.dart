import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';

import 'package:acadobs/features/news/data/models/news_model.dart';
import 'package:acadobs/features/news/data/services/news_service.dart';
import 'package:flutter/material.dart';

class NewsProvider extends ChangeNotifier {
  // ===========================================================================
  // COMMON STATE
  // ===========================================================================
  String? _error;
  String? get error => _error;

  void clearError() => _error = null;

  // ===========================================================================
  // LOADING STATES
  // ===========================================================================
  bool _isLoading = false; // For all news (paginated)
  bool get isLoading => _isLoading;

  bool _isLatestLoading = false; // For latest news (home)
  bool get isLatestLoading => _isLatestLoading;

  // ===========================================================================
  // PAGINATED NEWS (ALL)
  // ===========================================================================
  final List<News> _newsAll = [];
  List<News> get newsAll => List.unmodifiable(_newsAll);

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  Future<void> fetchNews({
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
        _newsAll.clear();
      }

      final response = await NewsService().fetchNews(
        forStaff: forStaff,
        pageNo: _currentPage,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'] ?? 1;
        _currentPage = data['currentPage'] ?? 1;

        final fetched =
            (data['news'] as List).map((e) => News.fromJson(e)).toList();

        _newsAll.addAll(fetched);

        if (_currentPage < _totalPages) {
          _currentPage++;
        }
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching news: $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // LATEST EVENTS (HOME)
  // ===========================================================================
  final List<News> _newsLatest = [];
  List<News> get newsLatest => List.unmodifiable(_newsLatest);

  Future<void> fetchLatestNews({required bool forStaff, int limit = 3}) async {
    if (_isLatestLoading) return;
    _isLatestLoading = true;
    notifyListeners();

    try {
      _newsLatest.clear();

      final response = await NewsService().fetchNews(
        forStaff: forStaff,
        pageNo: 1,
        limit: limit,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final fetched =
            (data['news'] as List).map((e) => News.fromJson(e)).toList();

        _newsLatest.addAll(fetched);
      }
    } catch (e) {
      _error = e.toString();
      log("Error fetching latest news: $_error");
    } finally {
      _isLatestLoading = false;
      notifyListeners();
    }
  }
}





// import 'dart:developer';

// import 'package:acadobs/features/news/data/models/news_model.dart';
// import 'package:acadobs/features/news/data/services/news_service.dart';
// import 'package:flutter/material.dart';

// class NewsProvider extends ChangeNotifier {
//   // ===========================================================================
//   // COMMON STATE
//   // ===========================================================================
//   String? _error;
//   String? get error => _error;

// // ===========================================================================
//   // LOADING STATES
//   // ===========================================================================
//   bool _isLoading = false;
//    bool get isLoading => _isLoading;

// // ===========================================================================
//   // PAGINATED EVENTS (ALL)
//   // ===========================================================================
//   List<News> _newsModel = [];
//   final List<News> _newsLatest = [];

 
//   List<News> get newsModel => _newsModel;
//   List<News> get latestNews => _newsLatest;

//   final NewsService _newsService = NewsService();

//   int _currentPage = 1;
//   bool _hasMore = true;

//   //distinguishing today event
//   List<News> get todayNews =>
//       _newsModel.where((e) {
//           final now = DateTime.now();
//           return now.year == e.date.year &&
//               now.month == e.date.month &&
//               now.day == e.date.day;
//         }).toList()
//         ..sort((a, b) => (b.createdAt).compareTo(a.createdAt));

//   //distinguishing yesterday event
//   List<News> get yesterdayNews =>
//       _newsModel.where((e) {
//           final now = DateTime.now();
//           final yesterday = now.subtract(Duration(days: 1));
//           return yesterday.year == e.date.year &&
//               yesterday.month == e.date.month &&
//               yesterday.day == e.date.day;
//         }).toList()
//         ..sort((a, b) => (b.createdAt).compareTo(a.createdAt));

//   //distinguishing earlier event
//   List<News> get earlierNews {
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));

//     return _newsModel.where((e) {
//         final created = DateTime(e.date.year, e.date.month, e.date.day);
//         return created.isBefore(yesterday);
//       }).toList()
//       ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
//   }

//   bool get hasMore => _hasMore;
//   int get currentpage => _currentPage;

//   Future<void> fetchLatestNews({
//     int pageNo = 1,
//     required bool forStaff,
//     bool isRefresh = false,
//     int limit = 10,
//   }) async {
//     if (_isLoading && !isRefresh) return;
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final response = await _newsService.fetchLatestNews(
//         pageNo: pageNo,
//         limit: limit,
//         forStaff: forStaff,
//       );
//       if (response.statusCode == 200) {
//         final data = response.data['news'];
//         final totalPages = response.data['totalPages'];

//         if (pageNo > totalPages) {
//           _hasMore = false;
//           _isLoading = false;
//           notifyListeners();
//           return;
//         }

//         final fetched = List<News>.from(data.map((e) => News.fromJson(e)));
//         fetched.sort((a, b) => b.createdAt.compareTo(a.createdAt));
//         if (isRefresh) {
//           _newsModel = fetched;
//           _currentPage = 1;
//           _hasMore = true;
//         } else {
//           final existingIds = _newsModel.map((e) => e.id).toSet();
//           final newNotices =
//               fetched.where((e) => !existingIds.contains(e.id)).toList();
//           _newsModel.addAll(newNotices);

//           _currentPage = pageNo;
//         }
//         _hasMore = _currentPage < totalPages;
//         _currentPage = pageNo;
//       } else {
//         _error = 'failed to fetch ${response.statusCode}';
//       }
//     } catch (e) {
//       _error = 'error: $e';
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> fetchHomeLatestNews({
//     int limit = 3,
//     required bool forStaff,
//   }) async {
//     _isLoading = true;
//     // notifyListeners();
//     try {
//       final response = await _newsService.fetchLatestNews(
//         pageNo: 1,
//         limit: limit,
//         forStaff: forStaff,
//       );
//       if (response.statusCode == 200) {
//         final data = response.data['news'];
//         final fetched = List<News>.from(data.map((e) => News.fromJson(e)));
//         fetched.sort((a, b) => b.createdAt.compareTo(a.createdAt));

//         _newsLatest
//           ..clear()
//           ..addAll(fetched.take(limit));
//         notifyListeners();
//       } else {
//         log("Failed to fetch latest home notices: ${response.statusCode}");
//       }
//     } catch (e) {
//       log("Error in fetchHomeLatestNotices: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void loadMore({required bool forStaff}) {
//     if (_hasMore && !_isLoading) {
//       fetchLatestNews(pageNo: _currentPage + 1, forStaff: forStaff);
//     }
//   }
// }
