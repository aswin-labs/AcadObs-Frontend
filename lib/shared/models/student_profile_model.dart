import 'dart:convert';

StudentProfile studentProfileFromJson(String str) => StudentProfile.fromJson(json.decode(str));

class StudentProfile {
    int id;
    String fullName;
    int rollNumber;
    int? classId;
    String? image;

    StudentProfile({
        required this.id,
        required this.fullName,
        required this.rollNumber,
        this.classId,
        this.image,
    });

    factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
        id: json["id"],
        fullName: json["full_name"],
        rollNumber: json["roll_number"],
        classId: json["class_id"],
        image: json["image"],
    );
}
