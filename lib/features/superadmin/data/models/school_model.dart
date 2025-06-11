
import 'dart:convert';

School schoolFromJson(String str) => School.fromJson(json.decode(str));

String schoolToJson(School data) => json.encode(data.toJson());

class School {
  int id;
  String name;
  String email;
  String phone;
  String address;
  String? logo;
  String status;
  bool trash;
  DateTime createdAt;
  DateTime updatedAt;

  School({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.logo,
    required this.status,
    required this.trash,
    required this.createdAt,
    required this.updatedAt,
  });

  factory School.fromJson(Map<String, dynamic> json) => School(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
        address: json["address"],
        logo: json["logo"],
        status: json["status"],
        trash: json["trash"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
        "address": address,
        "logo": logo,
        "status": status,
        "trash": trash,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
