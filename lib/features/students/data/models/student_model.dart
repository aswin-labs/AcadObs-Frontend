import 'dart:convert';

import 'package:acadobs/shared/models/class_grade_model.dart';
import 'package:acadobs/shared/models/user_model.dart';

StudentModel studentModelFromJson(String str) =>
    StudentModel.fromJson(json.decode(str));

class StudentModel {
  int id;
  int? schoolId;
  int? guardianId;
  String? regNo;
  int? rollNumber;
  String fullName;
  DateTime? dateOfBirth;
  String? gender;
  int? classId;
  DateTime? admissionDate;
  String? address;
  String? status;
  String? image;
  bool? alumni;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;
  ClassGradeModel? classGrade;
  UserModel? user;

  StudentModel({
    required this.id,
    this.schoolId,
    this.guardianId,
    this.regNo,
    this.rollNumber,
    required this.fullName,
    this.dateOfBirth,
    this.gender,
    this.classId,
    this.admissionDate,
    this.address,
    this.status,
    this.image,
    this.alumni,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.classGrade,
    this.user,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json["id"],
    schoolId: json["school_id"],
    guardianId: json["guardian_id"],
    regNo: json["reg_no"],
    rollNumber: json["roll_number"] ?? 0,
    fullName: json["full_name"],
    dateOfBirth:
        json["date_of_birth"] == null
            ? null
            : DateTime.parse(json["date_of_birth"]),
    gender: json["gender"],
    classId: json["class_id"],
    admissionDate:
        json["admission_date"] == null
            ? null
            : DateTime.parse(json["admission_date"]),
    address: json["address"],
    status: json["status"],
    image: json["image"],
    alumni: json["alumni"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    classGrade:
        json["Class"] == null ? null : ClassGradeModel.fromJson(json["Class"]),
    user: json["User"] == null ? null : UserModel.fromJson(json["User"]),
  );
}
