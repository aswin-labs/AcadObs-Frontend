import 'dart:convert';

import 'package:acadobs/shared/models/class_grade_model.dart';

StaffModel staffModelFromJson(String str) =>
    StaffModel.fromJson(json.decode(str));

class StaffModel {
  int? id;
  String? name;
  String? email;
  String? phone;
  dynamic dp;
  String? role;
  DateTime? createdAt;
  Staff? staff;

  StaffModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.dp,
    this.role,
    this.createdAt,
    this.staff,
  });

  factory StaffModel.fromJson(Map<String, dynamic> json) => StaffModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    dp: json["dp"],
    role: json["role"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    staff: json["Staff"] == null ? null : Staff.fromJson(json["Staff"]),
  );
}

class Staff {
  int? id;
  int? userId;
  int? schoolId;
  int? classId;
  String? role;
  dynamic qualification;
  String? address;
  List<dynamic>? staffSubjects;
  ClassGradeModel? staffClass;

  Staff({
    this.id,
    this.userId,
    this.schoolId,
    this.classId,
    this.role,
    this.qualification,
    this.address,
    this.staffSubjects,
    this.staffClass,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    id: json["id"],
    userId: json["user_id"],
    schoolId: json["school_id"],
    classId: json["class_id"],
    role: json["role"],
    qualification: json["qualification"],
    address: json["address"],
    staffSubjects:
        json["StaffSubjects"] == null
            ? []
            : List<dynamic>.from(json["StaffSubjects"]!.map((x) => x)),
    staffClass:
        json["Class"] == null ? null : ClassGradeModel.fromJson(json["Class"]),
  );
}
