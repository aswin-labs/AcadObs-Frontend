class TodayTransportationModel {
  final String? message;
  final StudentTransportationInfo? student;
  final RouteTransportationInfo? route;
  final List<TransportationStop> stops;
  final List<TransportationProgressData> data;

  TodayTransportationModel({
    this.message,
    this.student,
    this.route,
    this.stops = const [],
    this.data = const [],
  });

  factory TodayTransportationModel.fromJson(Map<String, dynamic> json) {
    return TodayTransportationModel(
      message: json["message"]?.toString(),
      student:
          json["student"] != null
              ? StudentTransportationInfo.fromJson(json["student"])
              : null,
      route:
          json["route"] != null
              ? RouteTransportationInfo.fromJson(json["route"])
              : null,
      stops:
          json["stops"] is List
              ? (json["stops"] as List)
                  .map((e) => TransportationStop.fromJson(e))
                  .toList()
              : [],
      data:
          json["data"] is List
              ? (json["data"] as List)
                  .map((e) => TransportationProgressData.fromJson(e))
                  .toList()
              : [],
    );
  }

  /// Returns stops sorted in ascending priority order
  List<TransportationStop> get sortedStops {
    final list = List<TransportationStop>.from(stops);
    list.sort((a, b) => a.priority.compareTo(b.priority));
    return list;
  }

  /// Helper to check if a specific stop has arrived
  bool isStopArrived(int? stopId) {
    if (stopId == null) return false;
    return data.any((d) => d.stopId == stopId);
  }

  /// Helper to get progress data for a stop
  TransportationProgressData? getProgressForStop(int? stopId) {
    if (stopId == null) return null;
    try {
      return data.firstWhere((d) => d.stopId == stopId);
    } catch (_) {
      return null;
    }
  }

  /// Get student stop status for a specific stop
  StudentStopStatus? getStudentStatusForStop(int? stopId, int? targetStudentId) {
    final progress = getProgressForStop(stopId);
    if (progress == null) return null;
    final sId = targetStudentId ?? student?.id;
    if (sId == null) return null;
    try {
      return progress.studentsStopStatuses.firstWhere(
        (s) => s.studentId == sId,
      );
    } catch (_) {
      return null;
    }
  }
}

class StudentTransportationInfo {
  final int? id;
  final String? fullName;
  final String? regNo;
  final int? routeId;
  final int? stopId;

  StudentTransportationInfo({
    this.id,
    this.fullName,
    this.regNo,
    this.routeId,
    this.stopId,
  });

  factory StudentTransportationInfo.fromJson(Map<String, dynamic> json) {
    return StudentTransportationInfo(
      id: _toInt(json["id"]),
      fullName: json["full_name"]?.toString(),
      regNo: json["reg_no"]?.toString(),
      routeId: _toInt(json["route_id"]),
      stopId: _toInt(json["stop_id"]),
    );
  }
}

class RouteTransportationInfo {
  final int? id;
  final String? routeName;
  final String? type;
  final bool? active;
  final VehicleTransportationInfo? vehicle;
  final DriverTransportationInfo? driver;

  RouteTransportationInfo({
    this.id,
    this.routeName,
    this.type,
    this.active,
    this.vehicle,
    this.driver,
  });

  factory RouteTransportationInfo.fromJson(Map<String, dynamic> json) {
    return RouteTransportationInfo(
      id: _toInt(json["id"]),
      routeName: json["route_name"]?.toString(),
      type: json["type"]?.toString(),
      active: json["active"] == true,
      vehicle:
          json["vehicle"] != null
              ? VehicleTransportationInfo.fromJson(json["vehicle"])
              : null,
      driver:
          json["driver"] != null
              ? DriverTransportationInfo.fromJson(json["driver"])
              : null,
    );
  }
}

class VehicleTransportationInfo {
  final int? id;
  final String? vehicleNumber;
  final String? type;
  final String? model;

  VehicleTransportationInfo({
    this.id,
    this.vehicleNumber,
    this.type,
    this.model,
  });

  factory VehicleTransportationInfo.fromJson(Map<String, dynamic> json) {
    return VehicleTransportationInfo(
      id: _toInt(json["id"]),
      vehicleNumber: json["vehicle_number"]?.toString(),
      type: json["type"]?.toString(),
      model: json["model"]?.toString(),
    );
  }
}

class DriverTransportationInfo {
  final int? id;
  final String? name;

  DriverTransportationInfo({this.id, this.name});

  factory DriverTransportationInfo.fromJson(Map<String, dynamic> json) {
    return DriverTransportationInfo(
      id: _toInt(json["id"]),
      name: json["name"]?.toString(),
    );
  }
}

class TransportationStop {
  final int? id;
  final String? stopName;
  final double? latitude;
  final double? longitude;
  final List<StopRoutePriority> stopRoutes;

  TransportationStop({
    this.id,
    this.stopName,
    this.latitude,
    this.longitude,
    this.stopRoutes = const [],
  });

  factory TransportationStop.fromJson(Map<String, dynamic> json) {
    return TransportationStop(
      id: _toInt(json["id"]),
      stopName: json["stop_name"]?.toString(),
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
      stopRoutes:
          json["StopRoutes"] is List
              ? (json["StopRoutes"] as List)
                  .map((e) => StopRoutePriority.fromJson(e))
                  .toList()
              : [],
    );
  }

  int get priority {
    if (stopRoutes.isNotEmpty && stopRoutes.first.priority != null) {
      return stopRoutes.first.priority!;
    }
    return 999;
  }
}

class StopRoutePriority {
  final int? priority;

  StopRoutePriority({this.priority});

  factory StopRoutePriority.fromJson(Map<String, dynamic> json) {
    return StopRoutePriority(priority: _toInt(json["priority"]));
  }
}

class TransportationProgressData {
  final double? latitude;
  final double? longitude;
  final int? routeId;
  final int? stopId;
  final TransportationStop? stop;
  final List<StudentStopStatus> studentsStopStatuses;

  TransportationProgressData({
    this.latitude,
    this.longitude,
    this.routeId,
    this.stopId,
    this.stop,
    this.studentsStopStatuses = const [],
  });

  factory TransportationProgressData.fromJson(Map<String, dynamic> json) {
    return TransportationProgressData(
      latitude: _toDouble(json["latitude"]),
      longitude: _toDouble(json["longitude"]),
      routeId: _toInt(json["route_id"]),
      stopId: _toInt(json["stop_id"]),
      stop:
          json["Stop"] != null
              ? TransportationStop.fromJson(json["Stop"])
              : null,
      studentsStopStatuses:
          json["StudentsStopStatuses"] is List
              ? (json["StudentsStopStatuses"] as List)
                  .map((e) => StudentStopStatus.fromJson(e))
                  .toList()
              : [],
    );
  }
}

class StudentStopStatus {
  final int? id;
  final int? studentId;
  final String? status; // picked, not_picked, dropped, not_dropped

  StudentStopStatus({this.id, this.studentId, this.status});

  factory StudentStopStatus.fromJson(Map<String, dynamic> json) {
    return StudentStopStatus(
      id: _toInt(json["id"]),
      studentId: _toInt(json["student_id"]),
      status: json["status"]?.toString(),
    );
  }

  bool get isPicked => status?.toLowerCase() == "picked";
  bool get isDropped => status?.toLowerCase() == "dropped";
  bool get isNotPicked => status?.toLowerCase() == "not_picked";
  bool get isNotDropped => status?.toLowerCase() == "not_dropped";
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}
