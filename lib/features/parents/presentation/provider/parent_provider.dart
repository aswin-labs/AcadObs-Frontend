import 'dart:developer';

import 'package:acadobs/features/parents/data/services/parent_services.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:flutter/material.dart';

class ParentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

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

  //change password
  Future<void> changePassword({
    required String newPassword,
    required String oldPassword,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ParentServices().changePassword(
        newPassword: newPassword,
        oldPassword: oldPassword,
      );
      if (response.statusCode == 200) {
        log("password changed successfully: ${response.data}");
        log("statuscode: ${response.statusCode}");
      } else {
        log("failed to change the password: ${response.data}");
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
