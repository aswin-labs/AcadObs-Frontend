class StudentRouteModel {
  int? id;
  String? fullName;
  String? regNo;
  RouteInfo? routes;

  StudentRouteModel({this.id, this.fullName, this.regNo, this.routes});

  factory StudentRouteModel.fromJson(Map<String, dynamic> json) =>
      StudentRouteModel(
        id: json["id"],
        fullName: json["full_name"],
        regNo: json["reg_no"],
        routes:
            json["routes"] == null ? null : RouteInfo.fromJson(json["routes"]),
      );
}

class RouteInfo {
  int? id;
  String? routeName;
  Vehicle? vehicle;
  Driver? driver;

  RouteInfo({this.id, this.routeName, this.vehicle, this.driver});

  factory RouteInfo.fromJson(Map<String, dynamic> json) => RouteInfo(
    id: json["id"],
    routeName: json["route_name"],
    vehicle:
        json["vehicle"] == null ? null : Vehicle.fromJson(json["vehicle"]),
    driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
  );
}

class Vehicle {
  int? id;
  String? vehicleNumber;
  String? type;
  String? photo;

  Vehicle({this.id, this.vehicleNumber, this.type, this.photo});

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json["id"],
    vehicleNumber: json["vehicle_number"],
    type: json["type"],
    photo: json["photo"],
  );
}

class Driver {
  int? id;
  String? name;

  Driver({this.id, this.name});

  factory Driver.fromJson(Map<String, dynamic> json) =>
      Driver(id: json["id"], name: json["name"]);
}

