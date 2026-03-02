import 'dart:developer';
import 'package:acadobs/features/tracking/data/models/guardian_stop_model.dart';
import 'package:acadobs/features/tracking/data/models/student_route_model.dart';
import 'package:acadobs/features/tracking/data/services/student_route_service.dart';
import 'package:flutter/material.dart';

class StudentRouteProvider extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  List<StudentRouteModel> _studentRoutes = [];
  List<StudentRouteModel> get studentRoutes => _studentRoutes;

  List<GuardianStopModel> _guardianStops = [];
  List<GuardianStopModel> get guardianStops => _guardianStops;

  int _routeCount = 0;
  int get routeCount => _routeCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> getStudentRoutes() async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await StudentRouteService().getStudentRoutes();
      if (response.statusCode == 200) {
        final data = response.data;
        _studentRoutes =
            (data['data'] as List<dynamic>)
                .map((res) => StudentRouteModel.fromJson(res))
                .toList();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //get route count
  Future<void> getRouteCount() async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await StudentRouteService().getRouteCount();
      if (response.statusCode == 200) {
        final data = response.data;
        _routeCount = data['total_routes'] ?? 0;
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //get arrived stops for guardian
  Future<void> getArrivedStopsForGuardian({required int routeId}) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await StudentRouteService().getArrivedStopsForGuardian(
        routeId: routeId,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        _guardianStops =
            (data['data'] as List<dynamic>)
                .map((res) => GuardianStopModel.fromJson(res))
                .toList();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
