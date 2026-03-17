class StudentRouteModel {
  int? id;
  String? fullName;
  String? regNo;
  List<Route>? routes;

  StudentRouteModel({this.id, this.fullName, this.regNo, this.routes});

  factory StudentRouteModel.fromJson(Map<String, dynamic> json) =>
      StudentRouteModel(
        id: json["id"],
        fullName: json["full_name"],
        regNo: json["reg_no"],
        routes:
            json["routes"] == null
                ? []
                : List<Route>.from(
                  json["routes"]!.map((x) => Route.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "reg_no": regNo,
    "routes":
        routes == null
            ? []
            : List<dynamic>.from(routes!.map((x) => x.toJson())),
  };
}

class Route {
  int? id;
  String? routeName;
  String? type;

  Route({this.id, this.routeName, this.type});

  factory Route.fromJson(Map<String, dynamic> json) =>
      Route(id: json["id"], routeName: json["route_name"], type: json["type"]);

  Map<String, dynamic> toJson() => {
    "id": id,
    "route_name": routeName,
    "type": type,
  };
}
