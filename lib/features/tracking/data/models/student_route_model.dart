import 'dart:convert';

StudentRouteModel studentRouteModelFromJson(String str) =>
    StudentRouteModel.fromJson(json.decode(str));

String studentRouteModelToJson(StudentRouteModel data) =>
    json.encode(data.toJson());

class StudentRouteModel {
  int? id;
  String? fullName;
  String? regNo;
  String? routeName;
  String? type;

  StudentRouteModel({
    this.id,
    this.fullName,
    this.regNo,
    this.routeName,
    this.type,
  });

  factory StudentRouteModel.fromJson(Map<String, dynamic> json) =>
      StudentRouteModel(
        id: json["id"],
        fullName: json["full_name"],
        regNo: json["reg_no"],
        routeName: json["route_name"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "reg_no": regNo,
    "route_name": routeName,
    "type": type,
  };
}
