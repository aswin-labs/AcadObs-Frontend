import 'dart:developer';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/parents/data/services/parent_services.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:flutter/material.dart';

class ParentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  String? _schoolName;
  String? get schoolName => _schoolName;

  final _authStorage = AuthStorageService();

  // school name
  Future<void> loadSchoolName() async {
    if (_schoolName != null) return;
    _schoolName = await _authStorage.getSchoolNameForParent();
    notifyListeners();
  }

  // fetch students under parent
  Future<void> fetchStudentsUnderParentBySchoolId() async {
    _isLoading = true;
    _students.clear();
    try {
      final response =
          await ParentServices().fetchStudentsUnderParentBySchoolId();
      _students =
          (response.data as List<dynamic>)
              .map((result) => StudentModel.fromJson(result))
              .toList();
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
