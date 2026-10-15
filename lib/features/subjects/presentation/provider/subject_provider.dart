import 'dart:developer';

import 'package:acadobs/features/subjects/data/services/subject_services.dart';
import 'package:acadobs/shared/models/subject_model.dart';
import 'package:flutter/material.dart';

class SubjectProvider extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  SubjectModel? _selectedSubject;
  SubjectModel? get selectedSubject => _selectedSubject;

  List<SubjectModel> schoolSubjects = [];
  List<SubjectModel> _subjectsAll = [];
  List<SubjectModel> get subjectsAll => _subjectsAll;
  int currentPage = 1;
  int lastPage = 1;
  bool isLoadingMore = false;

  bool get hasPetSubject => _subjectsAll.any((subject) {
        final name = subject.subjectName.trim().toUpperCase();
        return name == 'PET' || name == 'P.E.T' || name == 'P.E.T.';
      });

  // Fetch all subjects
  Future<void> fetchAllSubjects({bool loadMore = false}) async {
    _isLoading = true;

    try {
      final response = await SubjectServices().fetchStaffSubjects();
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch subjects');
      }
      final data = response.data;
      _subjectsAll =
          (data['subjects'] as List<dynamic>)
              .map((json) => SubjectModel.fromJson(json))
              .toList();
      log(response.data.toString());
    } catch (e) {
      log('Error fetching subjects: $e');
    } finally {
      _isLoading = false;
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
      await fetchAllSubjects();
      final subject = schoolSubjects.firstWhere((s) => s.id == subjectId);
      _selectedSubject = subject;
      notifyListeners();
    } catch (e) {
      log('Subject with ID $subjectId not found');
    }
  }
}
