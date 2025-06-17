import 'dart:developer';

import 'package:acadobs/core/utils/custom_snackbar.dart';
import 'package:acadobs/features/superadmin/data/models/school_model.dart';
import 'package:acadobs/features/superadmin/data/services/super_admin_services.dart';
import 'package:flutter/widgets.dart';

class SchoolController extends ChangeNotifier {
  bool _isloading = true;
  bool get isLoading => _isloading;

  bool _isLoadingTwo = false;
  bool get isLoadingTwo => _isLoadingTwo;

  List<School> schools = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isLoadingMore = false;
  bool _hasFetchedOnce = false;

  // Get all schools - with pagination and first-load guard
  Future<void> getAllSchools({bool loadMore = false}) async {
    if (!loadMore && _hasFetchedOnce) {
      return;
    }
    if (loadMore) {
      if (currentPage >= lastPage || isLoadingMore) return;

      isLoadingMore = true;
      currentPage += 1;
      notifyListeners();
    } else {
      _isloading = true;
      currentPage = 1;
      lastPage = 1;
      schools.clear();
      notifyListeners();
    }

    try {
      final response = await SuperAdminServices().getAllSchools(
        pageNo: currentPage,
      );
      final data = response.data;

      final List<dynamic> schoolList = data['schools'];
      final List<School> fetchedSchools =
          schoolList.map((json) => School.fromJson(json)).toList();

      schools.addAll(fetchedSchools);
      lastPage = data['totalPages'];

      _hasFetchedOnce = true; // ✅ set after first success
    } catch (e) {
      log('Error fetching schools: $e');
    } finally {
      _isloading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  // Add a new school
  Future<void> addSchool(
    context, {
    required String name,
    required String email,
    required String phone,
    required String address,
    required String adminPassword,
  }) async {
    _isLoadingTwo = true;
    _hasFetchedOnce = false;
    notifyListeners();

    try {
      final response = await SuperAdminServices().addSchool(
        context,
        name: name,
        email: email,
        phone: phone,
        address: address,
        adminPassword: adminPassword,
      );

      if (response.statusCode == 201) {
        log('School added successfully.');
        await getAllSchools();
        CustomSnackbar.show(
          context,
          message: 'School added successfully!',
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      } else {
        log('Failed to add school: ${response.statusCode}');
      }
    } catch (e) {
      log('Error adding school: $e');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Edit a school
  Future<void> editSchool(
    context, {
    required int schoolId,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    _isLoadingTwo = true;
    _hasFetchedOnce = false;
    notifyListeners();

    try {
      final response = await SuperAdminServices().editSchool(
        context,
        schoolId: schoolId,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );

      if (response.statusCode == 200) {
        log('School edited successfully.');
        await getAllSchools();
        CustomSnackbar.show(
          context,
          message: 'School edited successfully!',
          type: SnackbarType.success,
        );
        Navigator.pop(context);
      } else {
        log('Failed to edit school: ${response.statusCode}');
      }
    } catch (e) {
      log('Error editing school: $e');
    } finally {
      _isLoadingTwo = false;
      notifyListeners();
    }
  }

  // Delete a school
  Future<void> deleteSchool(context, {required int schoolId}) async {
    try {
      final response = await SuperAdminServices().deleteSchool(
        schoolId: schoolId,
      );
      if (response.statusCode == 200) {
        CustomSnackbar.show(
          context,
          message: 'Deleted successfully',
          type: SnackbarType.info,
        );
      } else {
        log('Failed to delete school: ${response.statusCode}');
      }
      schools.removeWhere((school) => school.id == schoolId);
      notifyListeners();
    } catch (e) {
      log('Error deleting school: $e');
    }
  }
}
