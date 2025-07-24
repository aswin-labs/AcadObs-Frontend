import 'dart:developer';

import 'package:acadobs/core/utils/custom_error_dialog.dart';
import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/teacher/data/models/homework/homework_model.dart';
import 'package:acadobs/features/teacher/data/services/homework_services.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeworkProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  final List<HomeworkModel> _homeworks = [];
  List<HomeworkModel> get homeworks => _homeworks;

  HomeworkModel? singleHomework;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  bool _isFetchedOnce = false;

  // Fetch homeworks
  Future<void> fetchHomeworks({
    bool loadMore = false,
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    // If not loading more, check if already fetched once.
    if (!loadMore && !forceRefresh && _isFetchedOnce) return;

    _isLoading = true;

    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _homeworks.clear();
        _isFetchedOnce = false;
      }
      final response = await HomeworkServices().fetchHomeworksByTeacher(
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List homeworksJson = data['homework'];

        final List<HomeworkModel> fetchHomeworks =
            homeworksJson
                .map((jsonItem) => HomeworkModel.fromJson(jsonItem))
                .toList();

        _homeworks.addAll(fetchHomeworks);
        _isFetchedOnce = true;
      } else {
        throw Exception('Failed to fetch homeworks: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create homework
  Future<void> createHomework({
    required BuildContext context,
    required int classId,
    required String title,
    required String description,
    required String dueDate,
    required int subjectId,
    required String type,
  }) async {
    _isLoadingTwo = true;
    notifyListeners();
    try {
      final selectedIds = context.read<SharedProvider>().selectedStudentIds;

      // Add validation here
      if (selectedIds.isEmpty) {
        CustomErrorDialog.show(context, "Please select at least one student");
        notifyListeners();
        return;
      }

      final studentIdList =
          selectedIds.map((id) => {"student_id": id}).toList();

      final response = await HomeworkServices().createHomework(
        context: context,
        classId: classId,
        title: title,
        description: description,
        dueDate: dueDate,
        subjectId: subjectId,
        type: type,
        studentIds: studentIdList,
      );

      if (response.statusCode == 201) {
        await fetchHomeworks(forceRefresh: true);
        if (!context.mounted) return;
        Navigator.pop(context);
        CustomSnackbar.show(
          context,
          message: "Homework Added Successfully",
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
      log(e.toString());
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Get Single homework
  Future<void> fetchSingleHomework({required int homeworkId}) async {
    _isLoading = true;
    try {
      final response = await HomeworkServices().fetchSingleHomework(
        homeworkId: homeworkId,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        singleHomework = HomeworkModel.fromJson(data);
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
