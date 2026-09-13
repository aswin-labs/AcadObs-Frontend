import 'dart:developer';
import 'package:acadobs/features/tracking/data/models/student_route_model.dart';
import 'package:acadobs/features/tracking/data/models/today_transportation_model.dart';
import 'package:acadobs/features/tracking/data/services/student_route_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class StudentRouteProvider extends ChangeNotifier {
  double? _latitude;
  double? _longitude;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  List<StudentRouteModel> _studentRoutes = [];
  List<StudentRouteModel> get studentRoutes => _studentRoutes;

  // final List<GuardianStopModel> _guardianStops = [];
  // List<GuardianStopModel> get guardianStops => _guardianStops;

  int _routeCount = 0;
  int get routeCount => _routeCount;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Independent Today Transportation State
  TodayTransportationModel? _todayTransportation;
  TodayTransportationModel? get todayTransportation => _todayTransportation;

  bool _isTransportationLoading = false;
  bool get isTransportationLoading => _isTransportationLoading;

  bool _isRouteInactive = false;
  bool get isRouteInactive => _isRouteInactive;

  String? _transportationError;
  String? get transportationError => _transportationError;

  Future<void> getTodayTransportationByStudentId({
    required int studentId,
  }) async {
    try {
      _isTransportationLoading = true;
      _transportationError = null;
      _isRouteInactive = false;
      notifyListeners();

      final response = await StudentRouteService()
          .getTodayTransportationByStudentId(studentId: studentId);

      log("Today Transportation API Response: ${response.data}");

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data is Map<String, dynamic>
                ? response.data as Map<String, dynamic>
                : Map<String, dynamic>.from(response.data as Map);
        _todayTransportation = TodayTransportationModel.fromJson(data);
        _transportationError = null;
        _isRouteInactive = false;
      } else {
        _todayTransportation = null;
        _transportationError =
            "Failed to load transportation details (${response.statusCode})";
      }
    } on DioException catch (e) {
      log("DioException fetching today transportation: $e");
      _todayTransportation = null;

      if (e.response?.statusCode == 404) {
        _isRouteInactive = true;
        final serverData = e.response?.data;
        String? serverMsg;
        if (serverData is Map) {
          serverMsg = (serverData['message'] ??
                  serverData['error'] ??
                  serverData['detail'])
              ?.toString();
        } else if (serverData is String && serverData.trim().isNotEmpty) {
          serverMsg = serverData.trim();
        }
        _transportationError = (serverMsg != null && serverMsg.isNotEmpty)
            ? serverMsg
            : "The transportation route is not active right now.";
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionError) {
        _isRouteInactive = false;
        _transportationError =
            "Unable to connect to the server. Please check your network connection.";
      } else {
        _isRouteInactive = false;
        final serverData = e.response?.data;
        String? serverMsg;
        if (serverData is Map) {
          serverMsg = (serverData['message'] ?? serverData['error'])?.toString();
        }
        _transportationError = serverMsg ??
            "Unable to load route information. Please try again later.";
      }
    } catch (e) {
      log("Error fetching today transportation: $e");
      _todayTransportation = null;
      _isRouteInactive = false;
      _transportationError =
          "An unexpected error occurred. Please try again later.";
    } finally {
      _isTransportationLoading = false;
      notifyListeners();
    }
  }

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

  // //get route count
  // Future<void> getRouteCount() async {
  //   try {
  //     _isLoading = true;
  //     notifyListeners();
  //     final response = await StudentRouteService().getRouteCount();
  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       log("data: $data ");
  //       _routeCount = data['total_routes'] ?? 0;
  //     }
  //   } catch (e) {
  //     log(e.toString());
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  //get stops for parent
  // Future<void> getStopsForParent({required int routeId}) async {
  //   try {
  //     _isLoading = true;
  //     notifyListeners();
  //     final response = await StudentRouteService().getStopsForParent(
  //       routeId: routeId,
  //     );
  //     if (response.statusCode == 200) {
  //       final data = response.data;
  //       _guardianStops =
  //           (data['data'] as List<dynamic>)
  //               .map((res) => GuardianStopModel.fromJson(res))
  //               .toList();
  //     }
  //   } catch (e) {
  //     log(e.toString());
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }
}
