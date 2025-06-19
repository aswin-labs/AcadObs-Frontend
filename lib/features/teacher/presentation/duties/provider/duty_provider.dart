import 'dart:developer';

import 'package:acadobs/features/teacher/data/models/staff_duty_model.dart';
import 'package:acadobs/features/teacher/data/services/duty_services.dart';
import 'package:flutter/material.dart';

class DutyProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final List<StaffDuty> _staffDuties = [];
  List<StaffDuty> get staffDuties => _staffDuties;

  int _currentPage = 1;
  int _totalPages = 1;

  bool get hasMore => _currentPage < _totalPages;

  // Reset staff duties
  void resetStaffDuties() {
    _staffDuties.clear();
    _currentPage = 1;
    _totalPages = 1;
    notifyListeners();
  }

  // Fetch Staff Duties
  Future<void> fetchStaffDuties({bool loadMore = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    
    try {
      if (loadMore) {
        _currentPage++;
      } else {
        _currentPage = 1;
        _staffDuties.clear();
      }
      final staffId = 3; //actually the userId of staff
      final response = await DutyServices().fetchStaffDuties(
        staffId: staffId,
        pageNo: _currentPage,
      );
      if (response.statusCode == 200) {
        final data = response.data;

        _totalPages = data['totalPages'];
        _currentPage = data['currentPage'];

        final List dutiesJson = data['duties'];

        final List<StaffDuty> fetchedDuties =
            dutiesJson.map((jsonItem) => StaffDuty.fromJson(jsonItem)).toList();

        _staffDuties.addAll(fetchedDuties);
        log(_staffDuties.toString());
      } else {
        throw Exception('Failed to fetch staff duties: ${response.statusCode}');
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
