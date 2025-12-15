import 'dart:developer';

import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';

import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/features/teacher/data/models/note_model.dart';
import 'package:acadobs/features/teacher/data/services/parent_note_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class ParentNoteProvider extends ChangeNotifier {
  final ParentNoteService _noteServices = ParentNoteService();
  List<Note> _note = [];
  List<Note> get note => _note;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  String? _error;
  bool _hasMore = true;
  String? get error => _error;
  bool get hasMore => _hasMore;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  // Note? notes;

  //distinguishing today event
  List<Note> get todayNote =>
      _note.where((e) {
          final now = DateTime.now();
          return now.year == e.createdAt!.year &&
              now.month == e.createdAt!.month &&
              now.day == e.createdAt!.day;
        }).toList()
        ..sort((a, b) => (b.createdAt)!.compareTo(a.createdAt!));

  //distinguishing yesterday event
  List<Note> get yesterdayNote =>
      _note.where((e) {
          final now = DateTime.now();
          final yesterday = now.subtract(Duration(days: 1));
          return yesterday.year == e.createdAt!.year &&
              yesterday.month == e.createdAt!.month &&
              yesterday.day == e.createdAt!.day;
        }).toList()
        ..sort((a, b) => (b.createdAt)!.compareTo(a.createdAt!));

  //distinguishing earlier event
  List<Note> get earlierNote {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return _note.where((e) {
        final created = DateTime(
          e.createdAt!.year,
          e.createdAt!.month,
          e.createdAt!.day,
        );
        return created.isBefore(yesterday);
      }).toList()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  Future<void> createParentNote({
    required BuildContext context,
    required String title,
    required String content,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final selectedIds = context.read<StudentProvider>().selectedStudentIds;
      if (selectedIds.isEmpty) {
        CustomErrorDialog.show(context, "Please select at least one student");
        _isLoadingTwo = false;
        notifyListeners();
        return;
      }
      final studentIdList =
          selectedIds.map((id) => {"student_id": id}).toList();

      final response = await ParentNoteService().createParentNote(
        context: context,
        title: title,
        content: content,
        studentIds: studentIdList,
      );
      if (response.statusCode == 201) {
        await fetchAllNotes();
        if (!context.mounted) return;
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Note Added Successfully",
          type: SnackbarType.success,
        );
      }
      if (response.statusCode == 200) {
        if (!context.mounted) return;
        CustomErrorDialog.show(context, response.data["message"]);
        _isLoadingTwo = false;
        notifyListeners();
      }
    } catch (e) {
      log('Error is : $e');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  //fetching all the notes
  Future<void> fetchAllNotes({
    int pageNo = 1,
    bool isRefresh = false,
    int limit = 10,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _noteServices.getParentNote(
        limit: limit,
        pageNo: pageNo,
      );
      log('full api response is: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data['notes'];

        final totalPages = response.data['totalPages'];

        if (pageNo > totalPages) {
          _hasMore = false;
          _isLoading = false;
          notifyListeners();
          return;
        }

        log("data is $data");

        final fetched = List<Note>.from(data.map((e) => Note.fromJson(e)));

        fetched.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
        if (isRefresh) {
          _note = fetched;
          _currentPage = 1;
          _hasMore = true;
        } else {
          // _notices.addAll(fetched); updated for the duplication
          final existingIds = _note.map((e) => e.id).toSet();
          final newNotices =
              fetched.where((e) => !existingIds.contains(e.id)).toList();
          _note.addAll(newNotices);

          _currentPage = pageNo;
        }
      } else {
        _error = 'failed to fetch notices ${response.statusCode}';
      }
    } catch (e) {
      log("Error is: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

Future<bool> deleteNote(int id) async {
  try {
    final response = await ParentNoteService().deleteNote(id: id);

    if (response.statusCode == 200 || response.statusCode == 204) {
      _note.removeWhere((n) => n.id == id);
      notifyListeners();
      return true; // success
    } else {
      log('Failed to delete note: ${response.statusCode}');
      return false; // failed
    }
  } catch (e) {
    log('Error deleting note: $e');
    return false; // failed
  }
}


  void loadMore() {
    if (_hasMore && !_isLoading) {
      fetchAllNotes(pageNo: _currentPage + 1);
    }
  }
}
