class GuardianStopModel {
  int? id;
  String? stopName;
  int? priority;
  String? routeName;
  String? routeType;
  bool? arrived;

  GuardianStopModel({
    this.id,
    this.stopName,
    this.priority,
    this.routeName,
    this.routeType,
    this.arrived,
  });

  factory GuardianStopModel.fromJson(Map<String, dynamic> json) =>
      GuardianStopModel(
        id: json["id"],
        stopName: json["stop_name"],
        priority: json["priority"],
        routeName: json["route_name"],
        routeType: json["route_type"],
        arrived: json["arrived"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "stop_name": stopName,
    "priority": priority,
    "route_name": routeName,
    "route_type": routeType,
    "arrived": arrived,
  };
}
