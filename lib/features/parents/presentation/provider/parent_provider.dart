import 'dart:developer';

import 'package:acadobs/core/utils/auth_storage_services.dart';
import 'package:acadobs/features/parents/data/services/parent_services.dart';
import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/shared/models/staff_model.dart';
import 'package:flutter/material.dart';

class ParentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<StudentModel> _students = [];
  List<StudentModel> get students => _students;

  String? _schoolName;
  String? get schoolName => _schoolName;

  final _authStorage = AuthStorageService();

  Map<String, dynamic>? _schoolDetails;
  Map<String, dynamic>? get schoolDetails => _schoolDetails;

  // Staffs / Teachers listing state
  final List<StaffModel> _staffs = [];
  List<StaffModel> get staffs => _staffs;

  int _currentPage = 1;
  int _totalPages = 1;
  bool get hasMoreStaffs => _currentPage < _totalPages;

  bool _isFetchedOnce = false;
  bool _isLoadingStaffs = false;
  bool get isLoadingStaffs => _isLoadingStaffs;
  String? _currentStaffQuery;

  // fetch school details for parent
  Future<void> fetchSchoolDetailsForParent({
    Map<String, dynamic>? freshDetails,
  }) async {
    try {
      if (freshDetails != null) {
        _schoolDetails = freshDetails;
        notifyListeners();
        return;
      }
      final schoolDetails = await _authStorage.getSchoolDetailsForParent();
      if (schoolDetails != null) {
        _schoolDetails = schoolDetails;
        notifyListeners();
      }
    } catch (e) {
      log('Error fetching school details for parent: $e');
    }
  }

  // fetch students under parent
  Future<void> fetchStudentsUnderParentBySchoolId({
    bool forceRefresh = false,
  }) async {
    if (_isLoading) return;

    if (!forceRefresh && _students.isNotEmpty) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response =
          await ParentServices().fetchStudentsUnderParentBySchoolId();

      _students =
          (response.data as List).map((e) => StudentModel.fromJson(e)).toList();
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // fetch staffs / teachers under school
  Future<void> fetchStaffsUnderSchool({
    bool loadMore = false,
    bool forceRefresh = false,
    String? query,
  }) async {
    if (_isLoadingStaffs) return;

    if (loadMore && !hasMoreStaffs) return;

    if (!loadMore && !forceRefresh && _isFetchedOnce && query == null) return;

    if (query != null) {
      _currentStaffQuery = query;
    } else if (!loadMore) {
      _currentStaffQuery = null;
    }

    _isLoadingStaffs = true;
    notifyListeners();

    try {
      final targetPage = loadMore ? _currentPage + 1 : 1;

      final response = await ParentServices().fetchStaffsUnderSchool(
        pageNo: targetPage,
        query: _currentStaffQuery,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        _totalPages = data['totalPages'] ?? 1;
        _currentPage = data['currentPage'] ?? targetPage;
        final List staffsJson = data['staffs'] ?? [];
        final List<StaffModel> fetchedStaffs =
            staffsJson
                .map((jsonItem) => StaffModel.fromJson(jsonItem))
                .toList();

        if (loadMore) {
          _staffs.addAll(fetchedStaffs);
        } else {
          _staffs.clear();
          _staffs.addAll(fetchedStaffs);
        }
        _isFetchedOnce = true;
      } else {
        throw Exception('Failed to fetch staff: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoadingStaffs = false;
      notifyListeners();
    }
  }
}
