import 'dart:convert';

TimeTableModel timeTableModelFromJson(String str) =>
    TimeTableModel.fromJson(json.decode(str));

String timeTableModelToJson(TimeTableModel data) => json.encode(data.toJson());

class TimeTableModel {
  int? id;
  int? schoolId;
  int? classId;
  int? dayOfWeek;
  int? periodNumber;
  int? subjectId;
  int? staffId;
  DateTime? createdAt;
  DateTime? updatedAt;
  User? user;
  Subject? subject;
  Class? timeTableModelClass;

  TimeTableModel({
    this.id,
    this.schoolId,
    this.classId,
    this.dayOfWeek,
    this.periodNumber,
    this.subjectId,
    this.staffId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.subject,
    this.timeTableModelClass,
  });

  factory TimeTableModel.fromJson(Map<String, dynamic> json) => TimeTableModel(
    id: json["id"],
    schoolId: json["school_id"],
    classId: json["class_id"],
    dayOfWeek: json["day_of_week"],
    periodNumber: json["period_number"],
    subjectId: json["subject_id"],
    staffId: json["staff_id"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    user: json["User"] == null ? null : User.fromJson(json["User"]),
    subject: json["Subject"] == null ? null : Subject.fromJson(json["Subject"]),
    timeTableModelClass:
        json["Class"] == null ? null : Class.fromJson(json["Class"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "school_id": schoolId,
    "class_id": classId,
    "day_of_week": dayOfWeek,
    "period_number": periodNumber,
    "subject_id": subjectId,
    "staff_id": staffId,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "User": user?.toJson(),
    "Subject": subject?.toJson(),
    "Class": timeTableModelClass?.toJson(),
  };
}

class Subject {
  int? id;
  String? subjectName;

  Subject({this.id, this.subjectName});

  factory Subject.fromJson(Map<String, dynamic> json) =>
      Subject(id: json["id"], subjectName: json["subject_name"]);

  Map<String, dynamic> toJson() => {"id": id, "subject_name": subjectName};
}

class Class {
  int? id;
  String? classname;

  Class({this.id, this.classname});

  factory Class.fromJson(Map<String, dynamic> json) =>
      Class(id: json["id"], classname: json["classname"]);

  Map<String, dynamic> toJson() => {"id": id, "classname": classname};
}

class User {
  int? id;
  String? name;

  User({this.id, this.name});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
