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

      log("API Response: ${response.data}");

      if (response.statusCode == 200) {
        _studentRoutes =
            (response.data['data'] as List)
                .map((e) => StudentRouteModel.fromJson(e))
                .toList();
        _routeCount = _studentRoutes.length;
      } else {
        log("Failed to fetch routes: ${response.statusCode}");
      }
    } catch (e) {
      log("Error fetching routes: $e");
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
        log("data: $data ");
        _routeCount = data['total_routes'] ?? 0;
      }
    } catch (e) {
      log(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //get stops for parent
  Future<void> getStopsForParent({required int routeId}) async {
    try {
      _isLoading = true;
      notifyListeners();
      final response = await StudentRouteService().getStopsForParent(
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
