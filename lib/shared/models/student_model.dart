import 'dart:convert';

StudentModel studentProfileFromJson(String str) =>
    StudentModel.fromJson(json.decode(str));

class StudentModel {
  int id;
  String fullName;
  int? rollNumber;
  int? classId;
  String? image;

  StudentModel({
    required this.id,
    required this.fullName,
    this.rollNumber,
    this.classId,
    this.image,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
    id: json["id"],
    fullName: json["full_name"],
    rollNumber: json["roll_number"],
    classId: json["class_id"],
    image: json["image"],
  );
}
