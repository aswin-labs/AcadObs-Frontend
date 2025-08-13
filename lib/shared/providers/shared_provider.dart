import 'dart:developer';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/shared/services/shared_services.dart';
import 'package:flutter/material.dart';

class SharedProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _classNames = [];
  List<Map<String, dynamic>> get classNames => _classNames;

  bool _isClassesEmpty = false;
  bool get isClassesEmpty => _isClassesEmpty;

  final List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  // Set<int> _selectedStudentIds = {};
  // bool get isAllSelected =>
  //     _students.isNotEmpty && _selectedStudentIds.length == _students.length;
  // Set<int> get selectedStudentIds => _selectedStudentIds;

  int? _classId;

  int? get classId => _classId;

  void setClassId(int? id) {
    _classId = id;
    notifyListeners();
  }

  void clearSelectedClassId() {
    _classId = null;
    notifyListeners();
  }

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

  // clear class names
  void resetClassNames() {
    _classNames.clear();
    _isClassesEmpty = false;
    notifyListeners();
  }

  // fetch students by class id
  // Future<void> fetchStudentsByClassId({required int classId}) async {
  //   _isLoading = true;
  //   _students.clear();
  //   try {
  //     final response = await StudentServices().fetchStudentsByClassId(
  //       classId: classId,
  //     );
  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       final List studentsJson = data['students'];
  //       final List<StudentModel> fetchedStudents =
  //           studentsJson
  //               .map((jsonItem) => StudentModel.fromJson(jsonItem))
  //               .toList();

  //       _students.addAll(fetchedStudents);
  //     } else {
  //       throw Exception('Failed to fetch staff duties: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     log(e.toString());
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // // clear students
  // void clearStudents() {
  //   _students.clear();
  //   notifyListeners();
  // }

  // // student selection
  // void toggleStudentSelection(int studentId) {
  //   if (_selectedStudentIds.contains(studentId)) {
  //     _selectedStudentIds.remove(studentId);
  //   } else {
  //     _selectedStudentIds.add(studentId);
  //   }
  //   notifyListeners();
  // }

  // // select all students
  // void selectAllStudents() {
  //   _selectedStudentIds = _students.map((e) => e.id).toSet();
  //   notifyListeners();
  // }

  // void deselectAllStudents() {
  //   _selectedStudentIds.clear();
  //   notifyListeners();
  // }
}
