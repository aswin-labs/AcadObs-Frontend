import 'dart:developer';

import 'package:acadobs/shared/models/student_model.dart';
import 'package:acadobs/shared/services/shared_services.dart';
import 'package:flutter/material.dart';

class SharedProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _classNames = [];
  List<Map<String, dynamic>> get classNames => _classNames;

  bool _isClassesEmpty = false;
  bool get isClassesEmpty => _isClassesEmpty;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  // Get Class names from standard
  Future<void> getClassNameFromStandard({
    required BuildContext context,
    required int standard,
  }) async {
    _isLoading = true;
    _isClassesEmpty = false;
    notifyListeners();
    try {
      final response = await SharedServices().getClassNameFromStandard(
        standard: standard,
      );
      if (response.statusCode == 200) {
        _classNames =
            (response.data as List<dynamic>)
                .map(
                  (result) => {
                    'id': result['id'],
                    'classname': result['classname'],
                  },
                )
                .toList();
        if (_classNames.isEmpty) {
          _isClassesEmpty = true;
        }
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getStudentsByClassId({required int classId}) async {
    _isLoading = true;
    _students.clear();
    try {
      final response = await SharedServices().getStudentsByClassId(
        classId: classId,
      );
      if (response.statusCode == 200) {
        _students =
            (response.data['students'] as List<dynamic>)
                .map((result) => StudentModel.fromJson(result))
                .toList();
        log(_students.toString());
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // clear class names
  void resetClassNames() {
    _classNames.clear();
    _isClassesEmpty = false;
    notifyListeners();
  }
}
