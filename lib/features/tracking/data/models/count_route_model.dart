import 'dart:convert';

String countRouteToJson(CountRoute data) => json.encode(data.toJson());

class CountRoute {
  String? message;
  int? totalRoutes;

  CountRoute({this.message, this.totalRoutes});

  factory CountRoute.fromJson(Map<String, dynamic> json) =>
      CountRoute(message: json["message"], totalRoutes: json["total_routes"]);

  Map<String, dynamic> toJson() => {
    "message": message,
    "total_routes": totalRoutes,
  };
}
