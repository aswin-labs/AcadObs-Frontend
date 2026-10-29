import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/parent_notes/data/models/parent_note_model.dart';
import 'package:acadobs/features/parent_notes/data/services/parent_note_services.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParentNotesProvider extends ChangeNotifier {
  final ParentNoteServices _services = ParentNoteServices();

  /// Extract a clean, user-friendly message from API or network errors
  String _getFriendlyErrorMessage(Object error, String fallbackMessage) {
    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map) {
        final serverMsg =
            responseData['message']?.toString() ??
            responseData['error']?.toString();
        if (serverMsg != null && serverMsg.trim().isNotEmpty) {
          return serverMsg.trim();
        }
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Request timed out. Please check your internet connection and try again.";
        case DioExceptionType.connectionError:
          return "No internet connection. Please check your network and try again.";
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 400 || statusCode == 422) {
            return "Unable to process your request. Please check the details and try again.";
          } else if (statusCode == 401 || statusCode == 403) {
            return "You do not have permission to perform this action.";
          } else if (statusCode == 404) {
            return "The requested parent note was not found.";
          } else if (statusCode != null && statusCode >= 500) {
            return "Server error occurred. Please try again later.";
          }
          break;
        default:
          break;
      }
    }
    return fallbackMessage;
  }

  List<ParentNoteModel> _notes = [];
  List<ParentNoteModel> get notes => _notes;

  ParentNoteModel? _singleNote;
  ParentNoteModel? get singleNote => _singleNote;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingNotes = false;
  bool get isLoadingNotes => _isLoadingNotes;

  bool _isLoadingSingleNote = false;
  bool get isLoadingSingleNote => _isLoadingSingleNote;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  int _totalPages = 1;
  int get totalPages => _totalPages;

  int _totalContent = 0;
  int get totalContent => _totalContent;

  String? _error;
  String? get error => _error;

  // ===========================================================================
  // GUARDIAN / STUDENT PARENT NOTES STATE
  // ===========================================================================
  List<ParentNoteModel> _studentNotes = [];
  List<ParentNoteModel> get studentNotes => _studentNotes;

  ParentNoteModel? _singleStudentNote;
  ParentNoteModel? get singleStudentNote => _singleStudentNote;

  bool _isLoadingStudentNotes = false;
  bool get isLoadingStudentNotes => _isLoadingStudentNotes;

  bool _isLoadingSingleStudentNote = false;
  bool get isLoadingSingleStudentNote => _isLoadingSingleStudentNote;

  bool _hasMoreStudentNotes = true;
  bool get hasMoreStudentNotes => _hasMoreStudentNotes;

  int _studentCurrentPage = 1;
  int get studentCurrentPage => _studentCurrentPage;

  int _studentTotalPages = 1;
  int get studentTotalPages => _studentTotalPages;

  int _studentTotalContent = 0;
  int get studentTotalContent => _studentTotalContent;

  String? _studentError;
  String? get studentError => _studentError;

  // Unseen parent note count per student (for guardian)
  final Map<int, int> _unseenNoteCounts = {};
  Map<int, int> get unseenNoteCounts => _unseenNoteCounts;

  int getUnseenNoteCount(int studentId) {
    return _unseenNoteCounts[studentId] ?? 0;
  }

  int get totalUnseenNoteCount =>
      _unseenNoteCounts.values.fold(0, (sum, count) => sum + count);

  /// Distinguish today's student notes
  List<ParentNoteModel> get todayStudentNotes =>
      _studentNotes.where((e) {
          if (e.createdAt == null) return false;
          final now = DateTime.now();
          return now.year == e.createdAt!.year &&
              now.month == e.createdAt!.month &&
              now.day == e.createdAt!.day;
        }).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

  /// Distinguish yesterday's student notes
  List<ParentNoteModel> get yesterdayStudentNotes =>
      _studentNotes.where((e) {
          if (e.createdAt == null) return false;
          final now = DateTime.now();
          final yesterday = now.subtract(const Duration(days: 1));
          return yesterday.year == e.createdAt!.year &&
              yesterday.month == e.createdAt!.month &&
              yesterday.day == e.createdAt!.day;
        }).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

  /// Distinguish earlier student notes
  List<ParentNoteModel> get earlierStudentNotes {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return _studentNotes.where((e) {
        if (e.createdAt == null) return false;
        final created = DateTime(
          e.createdAt!.year,
          e.createdAt!.month,
          e.createdAt!.day,
        );
        return created.isBefore(yesterday);
      }).toList()
      ..sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
  }

  /// Distinguish today's notes
  List<ParentNoteModel> get todayNotes =>
      _notes.where((e) {
          if (e.createdAt == null) return false;
          final now = DateTime.now();
          return now.year == e.createdAt!.year &&
              now.month == e.createdAt!.month &&
              now.day == e.createdAt!.day;
        }).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

  /// Distinguish yesterday's notes
  List<ParentNoteModel> get yesterdayNotes =>
      _notes.where((e) {
          if (e.createdAt == null) return false;
          final now = DateTime.now();
          final yesterday = now.subtract(const Duration(days: 1));
          return yesterday.year == e.createdAt!.year &&
              yesterday.month == e.createdAt!.month &&
              yesterday.day == e.createdAt!.day;
        }).toList()
        ..sort(
          (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
            a.createdAt ?? DateTime.now(),
          ),
        );

  /// Distinguish earlier notes
  List<ParentNoteModel> get earlierNotes {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return _notes.where((e) {
        if (e.createdAt == null) return false;
        final created = DateTime(
          e.createdAt!.year,
          e.createdAt!.month,
          e.createdAt!.day,
        );
        return created.isBefore(yesterday);
      }).toList()
      ..sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
  }

  /// Create parent note
  Future<void> createParentNote({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final selectedIds = context.read<StudentProvider>().selectedStudentIds;

      if (selectedIds.isEmpty) {
        CustomErrorDialog.show(context, "Please select at least one student");
        _isLoading = false;
        notifyListeners();
        return;
      }

      final studentIdList = selectedIds.toList();

      final response = await _services.createParentNote(
        context: context,
        title: title,
        content: content,
        studentIds: studentIdList,
      );

      if (response.statusCode == 201) {
        await fetchParentNotes(forceRefresh: true);
        if (!context.mounted) return;
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Parent Note Added Successfully",
          type: SnackbarType.success,
        );
      } else if (response.statusCode == 200) {
        if (response.data is Map && response.data["message"] != null) {
          if (!context.mounted) return;
          CustomSnackbar.show(
            context,
            message: response.data["message"].toString(),
            type: SnackbarType.success,
          );
          await fetchParentNotes(forceRefresh: true);
          if (context.mounted) Navigator.pop(context);
        } else {
          await fetchParentNotes(forceRefresh: true);
          if (context.mounted) Navigator.pop(context);
        }
      } else {
        if (!context.mounted) return;
        CustomErrorDialog.show(
          context,
          response.data is Map && response.data["message"] != null
              ? response.data["message"].toString()
              : "Unable to create parent note. Please try again.",
        );
      }
    } catch (e) {
      log("Error creating parent note: $e");
      if (context.mounted) {
        CustomErrorDialog.show(
          context,
          _getFriendlyErrorMessage(
            e,
            "Unable to create parent note. Please try again.",
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update parent note
  Future<bool> updateParentNote({
    required BuildContext context,
    required int noteId,
    required String title,
    required String content,
    List<int>? studentIds,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _services.updateParentNote(
        context: context,
        noteId: noteId,
        title: title,
        content: content,
        studentIds: studentIds,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchSingleParentNote(noteId: noteId);
        await fetchParentNotes(forceRefresh: true);
        if (!context.mounted) return true;
        CustomSnackbar.show(
          context,
          message: "Parent Note updated successfully",
          type: SnackbarType.success,
        );
        return true;
      } else {
        if (!context.mounted) return false;
        CustomErrorDialog.show(
          context,
          response.data is Map && response.data["message"] != null
              ? response.data["message"].toString()
              : "Unable to update parent note. Please try again.",
        );
        return false;
      }
    } catch (e) {
      log("Error updating parent note: $e");
      if (context.mounted) {
        CustomErrorDialog.show(
          context,
          _getFriendlyErrorMessage(
            e,
            "Unable to update parent note. Please try again.",
          ),
        );
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch parent notes with pagination and refresh support
  Future<void> fetchParentNotes({
    bool forceRefresh = false,
    bool loadMore = false,
    bool clearExisting = false,
    int? limit,
  }) async {
    if (_isLoadingNotes) return;
    if (loadMore && !_hasMore) return;

    final int effectiveLimit = limit ?? AppConstants.paginationLimit;
    final int targetPage =
        forceRefresh ? 1 : (loadMore ? (_currentPage + 1) : 1);

    if (clearExisting) {
      _notes.clear();
      _currentPage = 1;
      _hasMore = true;
    }

    _isLoadingNotes = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _services.fetchParentNotes(
        pageNo: targetPage,
        limit: effectiveLimit,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final listResponse = ParentNoteListResponse.fromJson(responseData);
          final fetched = listResponse.notes;

          _totalContent = listResponse.totalContent ?? fetched.length;
          _currentPage = listResponse.currentPage ?? targetPage;

          if (listResponse.totalPages != null) {
            _totalPages = listResponse.totalPages!;
            _hasMore = fetched.isNotEmpty && _currentPage < _totalPages;
          } else {
            _totalPages =
                _totalContent > 0
                    ? (_totalContent / effectiveLimit).ceil()
                    : 1;
            _hasMore = fetched.length >= effectiveLimit;
          }

          if (targetPage == 1) {
            _notes = fetched;
          } else {
            final existingIds = _notes.map((e) => e.id).toSet();
            final newNotes =
                fetched.where((e) => !existingIds.contains(e.id)).toList();
            if (newNotes.isEmpty) {
              _hasMore = false;
            } else {
              _notes.addAll(newNotes);
            }
          }
        } else if (responseData is List) {
          final fetched =
              responseData
                  .whereType<Map<String, dynamic>>()
                  .map((e) => ParentNoteModel.fromJson(e))
                  .toList();
          _currentPage = targetPage;
          _hasMore = fetched.length >= effectiveLimit;
          if (targetPage == 1) {
            _notes = fetched;
          } else {
            final existingIds = _notes.map((e) => e.id).toSet();
            final newNotes =
                fetched.where((e) => !existingIds.contains(e.id)).toList();
            if (newNotes.isEmpty) {
              _hasMore = false;
            } else {
              _notes.addAll(newNotes);
            }
          }
        }
      } else {
        if (loadMore) _hasMore = false;
        _error = "Unable to load parent notes. Please try again.";
      }
    } catch (e) {
      log("Error fetching parent notes: $e");
      if (loadMore) _hasMore = false;
      _error = _getFriendlyErrorMessage(
        e,
        "Unable to load parent notes. Please try again.",
      );
    } finally {
      _isLoadingNotes = false;
      notifyListeners();
    }
  }

  /// Fetch single parent note
  Future<void> fetchSingleParentNote({required int noteId}) async {
    _isLoadingSingleNote = true;
    _singleNote = null;
    notifyListeners();
    try {
      final response = await _services.fetchSingleParentNote(noteId: noteId);
      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final data =
            raw is Map<String, dynamic>
                ? (raw['note'] ?? raw['data'] ?? raw)
                : raw;
        if (data is Map<String, dynamic>) {
          _singleNote = ParentNoteModel.fromJson(data);
        }
      }
    } catch (e) {
      log("Error fetching single parent note: $e");
    } finally {
      _isLoadingSingleNote = false;
      notifyListeners();
    }
  }

  /// Delete parent note
  Future<bool> deleteParentNote({
    required BuildContext context,
    required int noteId,
  }) async {
    try {
      final response = await _services.deleteParentNote(noteId: noteId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        _notes.removeWhere((n) => n.id == noteId);
        notifyListeners();
        return true;
      } else {
        log("Failed to delete note: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      log("Error deleting parent note: $e");
      return false;
    }
  }

  /// Clear any error or temporary state
  void clearState() {
    _error = null;
    _studentError = null;
    _isLoading = false;
    notifyListeners();
  }

  // ===========================================================================
  // GUARDIAN / STUDENT PARENT NOTES METHODS
  // ===========================================================================

  /// Fetch parent notes for a student with pagination and refresh support
  Future<void> fetchParentNotesByStudentId({
    required int studentId,
    bool forceRefresh = false,
    bool loadMore = false,
    bool clearExisting = false,
    int? limit,
  }) async {
    if (_isLoadingStudentNotes) return;
    if (loadMore && !_hasMoreStudentNotes) return;

    final int effectiveLimit = limit ?? AppConstants.paginationLimit;
    final int targetPage =
        forceRefresh ? 1 : (loadMore ? (_studentCurrentPage + 1) : 1);

    if (clearExisting) {
      _studentNotes.clear();
      _studentCurrentPage = 1;
      _hasMoreStudentNotes = true;
    }

    _isLoadingStudentNotes = true;
    _studentError = null;
    notifyListeners();

    try {
      final response = await _services.fetchParentNotesByStudentId(
        studentId: studentId,
        pageNo: targetPage,
        limit: effectiveLimit,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final listResponse = ParentNoteListResponse.fromJson(responseData);
          final fetched = listResponse.notes;

          _studentTotalContent = listResponse.totalContent ?? fetched.length;
          _studentCurrentPage = listResponse.currentPage ?? targetPage;

          if (listResponse.totalPages != null) {
            _studentTotalPages = listResponse.totalPages!;
            _hasMoreStudentNotes =
                fetched.isNotEmpty && _studentCurrentPage < _studentTotalPages;
          } else {
            _studentTotalPages =
                _studentTotalContent > 0
                    ? (_studentTotalContent / effectiveLimit).ceil()
                    : 1;
            _hasMoreStudentNotes = fetched.length >= effectiveLimit;
          }

          if (targetPage == 1) {
            _studentNotes = fetched;
          } else {
            final existingIds = _studentNotes.map((e) => e.id).toSet();
            final newNotes =
                fetched.where((e) => !existingIds.contains(e.id)).toList();
            if (newNotes.isEmpty) {
              _hasMoreStudentNotes = false;
            } else {
              _studentNotes.addAll(newNotes);
            }
          }
        } else if (responseData is List) {
          final fetched =
              responseData
                  .whereType<Map<String, dynamic>>()
                  .map((e) => ParentNoteModel.fromJson(e))
                  .toList();
          _studentCurrentPage = targetPage;
          _hasMoreStudentNotes = fetched.length >= effectiveLimit;
          if (targetPage == 1) {
            _studentNotes = fetched;
          } else {
            final existingIds = _studentNotes.map((e) => e.id).toSet();
            final newNotes =
                fetched.where((e) => !existingIds.contains(e.id)).toList();
            if (newNotes.isEmpty) {
              _hasMoreStudentNotes = false;
            } else {
              _studentNotes.addAll(newNotes);
            }
          }
        }
      } else {
        if (loadMore) _hasMoreStudentNotes = false;
        _studentError = "Unable to load parent notes. Please try again.";
      }
    } catch (e) {
      log("Error fetching student parent notes: $e");
      if (loadMore) _hasMoreStudentNotes = false;
      _studentError = _getFriendlyErrorMessage(
        e,
        "Unable to load parent notes. Please try again.",
      );
    } finally {
      _isLoadingStudentNotes = false;
      notifyListeners();
    }
  }

  /// Fetch single parent note by noteId and studentId (Guardian view)
  Future<void> fetchSingleParentNoteByStudentId({
    required int noteId,
    required int studentId,
  }) async {
    _isLoadingSingleStudentNote = true;
    _singleStudentNote = null;
    notifyListeners();

    try {
      final response = await _services.fetchParentNoteByIdAndStudentId(
        noteId: noteId,
        studentId: studentId,
      );
      if (response.statusCode == 200) {
        final dynamic raw = response.data;
        final data =
            raw is Map<String, dynamic>
                ? (raw['note'] ?? raw['data'] ?? raw)
                : raw;
        if (data is Map<String, dynamic>) {
          _singleStudentNote = ParentNoteModel.fromJson(data);

          // Update the corresponding note in _studentNotes list
          final idx = _studentNotes.indexWhere((n) => n.id == noteId);
          if (idx != -1 && _singleStudentNote != null) {
            final updatedStudents =
                (_singleStudentNote!.parentNoteStudents ?? [])
                    .map(
                      (s) => ParentNoteStudentModel(
                        id: s.id,
                        studentId: s.studentId,
                        isSeen: true,
                        student: s.student,
                      ),
                    )
                    .toList();
            _studentNotes[idx] = ParentNoteModel(
              id: _singleStudentNote!.id,
              schoolId: _singleStudentNote!.schoolId,
              noteTitle: _singleStudentNote!.noteTitle,
              noteContent: _singleStudentNote!.noteContent,
              noteAttachment: _singleStudentNote!.noteAttachment,
              recordedBy: _singleStudentNote!.recordedBy,
              trash: _singleStudentNote!.trash,
              createdAt: _singleStudentNote!.createdAt,
              updatedAt: _singleStudentNote!.updatedAt,
              parentNoteStudents: updatedStudents,
            );
          }
        }
        // Refresh unseen count for this student after viewing the note
        await getUnseenParentNoteCountByStudentId(studentId: studentId);
      }
    } catch (e) {
      log("Error fetching single student parent note: $e");
    } finally {
      _isLoadingSingleStudentNote = false;
      notifyListeners();
    }
  }

  /// Fetch unseen parent note count for a single student
  Future<int> getUnseenParentNoteCountByStudentId({
    required int studentId,
  }) async {
    try {
      final response = await _services.fetchUnseenParentNoteCountByStudentId(
        studentId: studentId,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final dynamic rawCount =
            data is Map
                ? (data["unseenCount"] ?? data["unseenParentNoteCount"])
                : null;
        final int count =
            rawCount is int
                ? rawCount
                : int.tryParse(rawCount?.toString() ?? '0') ?? 0;

        _unseenNoteCounts[studentId] = count;
        notifyListeners();
        return count;
      }
    } catch (e) {
      log("Error getting unseen parent note count: $e");
    }
    return _unseenNoteCounts[studentId] ?? 0;
  }

  /// Fetch unseen parent note counts for multiple students
  Future<void> fetchUnseenCountsForStudents(List<int> studentIds) async {
    if (studentIds.isEmpty) return;
    await Future.wait(
      studentIds.map((id) => getUnseenParentNoteCountByStudentId(studentId: id)),
    );
  }
}
