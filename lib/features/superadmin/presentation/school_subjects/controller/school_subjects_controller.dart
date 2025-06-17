import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/superadmin/data/models/school_subject_model.dart';
import 'package:acadobs/features/superadmin/data/services/super_admin_services.dart';
import 'package:flutter/material.dart';

class SchoolSubjectsController extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  List<SchoolSubject> schoolSubjects = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isLoadingMore = false;
  bool _hasFetchedOnce = false;

  // Get all subjects - Pagination
  Future<void> getAllSchoolSubjects({bool loadMore = false}) async {
    if (!loadMore && _hasFetchedOnce) {
      return;
    }
    if (loadMore) {
      if (currentPage >= lastPage || isLoadingMore) return;
      isLoadingMore = true;
      currentPage += 1; // ✅ move increment here
      notifyListeners();
    } else {
      _isLoading = true;
      currentPage = 1;
      schoolSubjects.clear();
      notifyListeners();
    }

    try {
      final response = await SuperAdminServices().getAllSubjects(
        pageNo: currentPage,
      );
      final data = response.data;

      final List<dynamic> schoolSubjectsList = data['subjects'];
      final List<SchoolSubject> fetchedSubjects =
          schoolSubjectsList
              .map((json) => SchoolSubject.fromJson(json))
              .toList();

      schoolSubjects.addAll(fetchedSubjects);

      lastPage = data['totalPages'];
      _hasFetchedOnce = true;
    } catch (e) {
      log('Error fetching subjects: $e');
    } finally {
      _isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  // Add a new subject
  Future<void> addNewSubject(
    context, {
    required String subjectName,
    required String classRange,
  }) async {
    _isLoadingTwo = true;
    _hasFetchedOnce = false;
    notifyListeners();

    try {
      final response = await SuperAdminServices().addSubject(
        subjectName: subjectName,
        classRange: classRange,
      );

      if (response.statusCode == 201) {
        log('Subject added successfully.');
        await getAllSchoolSubjects();
        CustomSnackbar.show(
          context,
          message: 'Subject added successfully!',
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      } else {
        log('Failed to add subject: ${response.statusCode}');
      }
    } catch (e) {
      log('Error adding subject: $e');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Edit a subject
  Future<void> editSubject(
    context, {
    required int subjectId,
    required String subjectName,
    required String classRange,
  }) async {
    _isLoadingTwo = true;
    _hasFetchedOnce = false;
    notifyListeners();

    try {
      final response = await SuperAdminServices().editSubject(
        subjectId: subjectId,
        subjectName: subjectName,
        classRange: classRange,
      );

      if (response.statusCode == 200) {
        log('Subject edited successfully.');
        await getAllSchoolSubjects();
        CustomSnackbar.show(
          context,
          message: 'Subject edited successfully!',
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      } else {
        log('Failed to edit subject: ${response.statusCode}');
      }
    } catch (e) {
      log('Error editing subject: $e');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Delete a subject
  Future<void> deleteSubject(context, {required int subjectId}) async {
    try {
      final response = await SuperAdminServices().deleteSubject(
        subjectId: subjectId,
      );
      if (response.statusCode == 200) {
        CustomSnackbar.show(
          context,
          message: 'Deleted successfully',
          type: SnackbarType.info,
        );
      } else {
        log('Failed to delete subject: ${response.statusCode}');
      }
      schoolSubjects.removeWhere((subject) => subject.id == subjectId);
      notifyListeners();
    } catch (e) {
      log('Error deleting subject: $e');
    }
  }
}
