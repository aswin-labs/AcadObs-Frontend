import 'dart:convert';

SchoolClass schoolClassFromJson(String str) =>
    SchoolClass.fromJson(json.decode(str));

String schoolClassToJson(SchoolClass data) => json.encode(data.toJson());

class SchoolClass {
  int id;
  int year;
  String? division;
  String classname;
  int? schoolId;
  bool trash;
  DateTime createdAt;
  DateTime updatedAt;

  SchoolClass({
    required this.id,
    required this.year,
    this.division,
    required this.classname,
    this.schoolId,
    required this.trash,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) => SchoolClass(
        id: json["id"],
        year: json["year"],
        division: json["division"],
        classname: json["classname"],
        schoolId: json["school_id"],
        trash: json["trash"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "year": year,
        "division": division,
        "classname": classname,
        "school_id": schoolId,
        "trash": trash,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}
