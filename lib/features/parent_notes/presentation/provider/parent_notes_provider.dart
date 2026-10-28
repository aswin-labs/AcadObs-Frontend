import 'dart:developer';

import 'package:acadobs/core/constants/app_constants.dart';
import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/parent_notes/data/models/parent_note_model.dart';
import 'package:acadobs/features/parent_notes/data/services/parent_note_services.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ParentNotesProvider extends ChangeNotifier {
  final ParentNoteServices _services = ParentNoteServices();

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
          response.data?["message"]?.toString() ??
              "Failed to create parent note (${response.statusCode})",
        );
      }
    } catch (e) {
      log("Error creating parent note: $e");
      if (context.mounted) {
        CustomErrorDialog.show(context, "Failed to create parent note: $e");
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
          response.data?["message"]?.toString() ??
              "Failed to update parent note (${response.statusCode})",
        );
        return false;
      }
    } catch (e) {
      log("Error updating parent note: $e");
      if (context.mounted) {
        CustomErrorDialog.show(context, "Failed to update parent note: $e");
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
    int? limit,
  }) async {
    if (_isLoadingNotes) return;

    if (forceRefresh) {
      _currentPage = 1;
      _hasMore = true;
      _notes.clear();
    } else if (loadMore) {
      if (!_hasMore) return;
      _currentPage++;
    }

    _isLoadingNotes = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _services.fetchParentNotes(
        pageNo: _currentPage,
        limit: limit ?? AppConstants.paginationLimit,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final listResponse = ParentNoteListResponse.fromJson(responseData);
          _totalContent = listResponse.totalContent ?? 0;
          _totalPages = listResponse.totalPages ?? 1;
          _currentPage = listResponse.currentPage ?? _currentPage;
          _hasMore = _currentPage < _totalPages;

          final fetched = listResponse.notes;
          if (forceRefresh || _currentPage == 1) {
            _notes = fetched;
          } else {
            final existingIds = _notes.map((e) => e.id).toSet();
            final newNotes =
                fetched.where((e) => !existingIds.contains(e.id)).toList();
            _notes.addAll(newNotes);
          }
        } else if (responseData is List) {
          final fetched =
              responseData.map((e) => ParentNoteModel.fromJson(e)).toList();
          _hasMore = fetched.length >= (limit ?? AppConstants.paginationLimit);
          if (forceRefresh || _currentPage == 1) {
            _notes = fetched;
          } else {
            _notes.addAll(fetched);
          }
        }
      } else {
        _error = "Failed to fetch parent notes: ${response.statusCode}";
      }
    } catch (e) {
      log("Error fetching parent notes: $e");
      _error = e.toString();
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
    _isLoading = false;
    notifyListeners();
  }
}
