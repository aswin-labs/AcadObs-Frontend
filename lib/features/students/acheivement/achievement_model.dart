import 'dart:convert';

AchievementModel achievementModelFromJson(String str) =>
    AchievementModel.fromJson(json.decode(str));

String achievementModelToJson(AchievementModel data) =>
    json.encode(data.toJson());

class AchievementModel {
  int? id;
  int? schoolId;
  String? title;
  String? description;
  String? category;
  String? level;
  DateTime? date;
  String? awardingBody;
  int? recordedBy;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<StudentAchievement>? studentAchievements;

  AchievementModel({
    this.id,
    this.schoolId,
    this.title,
    this.description,
    this.category,
    this.level,
    this.date,
    this.awardingBody,
    this.recordedBy,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.studentAchievements,
  });

  factory AchievementModel.fromJson(
    Map<String, dynamic> json,
  ) => AchievementModel(
    id: json["id"],
    schoolId: json["school_id"],
    title: json["title"],
    description: json["description"],
    category: json["category"],
    level: json["level"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    awardingBody: json["awarding_body"],
    recordedBy: json["recorded_by"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    studentAchievements:
        json["StudentAchievements"] == null
            ? []
            : List<StudentAchievement>.from(
              json["StudentAchievements"]!.map(
                (x) => StudentAchievement.fromJson(x),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "school_id": schoolId,
    "title": title,
    "description": description,
    "category": category,
    "level": level,
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "awarding_body": awardingBody,
    "recorded_by": recordedBy,
    "trash": trash,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "StudentAchievements":
        studentAchievements == null
            ? []
            : List<dynamic>.from(studentAchievements!.map((x) => x.toJson())),
  };
}

class StudentAchievement {
  int? studentId;
  String? status;
  dynamic proofDocument;
  String? remarks;
  Student? student;

  StudentAchievement({
    this.studentId,
    this.status,
    this.proofDocument,
    this.remarks,
    this.student,
  });

  factory StudentAchievement.fromJson(Map<String, dynamic> json) =>
      StudentAchievement(
        studentId: json["student_id"],
        status: json["status"],
        proofDocument: json["proof_document"],
        remarks: json["remarks"],
        student:
            json["Student"] == null ? null : Student.fromJson(json["Student"]),
      );

  Map<String, dynamic> toJson() => {
    "student_id": studentId,
    "status": status,
    "proof_document": proofDocument,
    "remarks": remarks,
    "Student": student?.toJson(),
  };
}

class Student {
  int? id;
  String? fullName;
  String? regNo;
  String? image;
  Class? studentClass;

  Student({this.id, this.fullName, this.regNo, this.image, this.studentClass});

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json["id"],
    fullName: json["full_name"],
    regNo: json["reg_no"],
    image: json["image"],
    studentClass: json["Class"] == null ? null : Class.fromJson(json["Class"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "reg_no": regNo,
    "image": image,
    "Class": studentClass?.toJson(),
  };
}

class Class {
  int? id;
  String? classname;
  int? year;
  String? division;

  Class({this.id, this.classname, this.year, this.division});

  factory Class.fromJson(Map<String, dynamic> json) => Class(
    id: json["id"],
    classname: json["classname"],
    year: json["year"],
    division: json["division"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "classname": classname,
    "year": year,
    "division": division,
  };
}
