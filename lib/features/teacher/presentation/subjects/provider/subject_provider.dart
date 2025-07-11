import 'dart:developer';

import 'package:acadobs/features/superadmin/data/services/super_admin_services.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:flutter/material.dart';

class SubjectProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SubjectModel? _selectedSubject;
  SubjectModel? get selectedSubject => _selectedSubject;

  List<SubjectModel> schoolSubjects = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isLoadingMore = false;
  bool _hasFetchedOnce = false;

  // Fetch all subjects
  Future<void> fetchSubjects({bool loadMore = false}) async {
    if (!loadMore && _hasFetchedOnce) {
      return;
    }
    if (loadMore) {
      if (currentPage >= lastPage || isLoadingMore) return;
      isLoadingMore = true;
      currentPage += 1;
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
      final List<SubjectModel> fetchedSubjects =
          schoolSubjectsList
              .map((json) => SubjectModel.fromJson(json))
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

  // Select subject
  void selectSubject(SubjectModel subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSubject = null;
    notifyListeners();
  }

  // set subject selected
  void setSubjectSelected(int subjectId) async {
    try {
      await fetchSubjects();
      final subject = schoolSubjects.firstWhere((s) => s.id == subjectId);
      _selectedSubject = subject;
      notifyListeners();
    } catch (e) {
      log('Subject with ID $subjectId not found');
    }
  }
}
