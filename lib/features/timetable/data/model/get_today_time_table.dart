import 'dart:convert';

GetTodayTimeTable getTodayTimeTableFromJson(String str) =>
    GetTodayTimeTable.fromJson(json.decode(str));

String getTodayTimeTableToJson(GetTodayTimeTable data) =>
    json.encode(data.toJson());

class GetTodayTimeTable {
  int? dayOfWeek;
  List<Period>? periods;

  GetTodayTimeTable({this.dayOfWeek, this.periods});

  factory GetTodayTimeTable.fromJson(Map<String, dynamic> json) =>
      GetTodayTimeTable(
        dayOfWeek: json["day_of_week"],
        periods:
            json["periods"] == null
                ? []
                : List<Period>.from(
                  json["periods"]!.map((x) => Period.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "day_of_week": dayOfWeek,
    "periods":
        periods == null
            ? []
            : List<dynamic>.from(periods!.map((x) => x.toJson())),
  };
}

class Period {
  int? id;
  int? dayOfWeek;
  int? periodNumber;
  int? subjectId;
  int? staffId;
  DateTime? createdAt;
  User? user;
  Subject? subject;
  Class? periodClass;

  Period({
    this.id,
    this.dayOfWeek,
    this.periodNumber,
    this.subjectId,
    this.staffId,
    this.createdAt,
    this.user,
    this.subject,
    this.periodClass,
  });

  factory Period.fromJson(Map<String, dynamic> json) => Period(
    id: json["id"],
    dayOfWeek: json["day_of_week"],
    periodNumber: json["period_number"],
    subjectId: json["subject_id"],
    staffId: json["staff_id"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    user: json["User"] == null ? null : User.fromJson(json["User"]),
    subject: json["Subject"] == null ? null : Subject.fromJson(json["Subject"]),
    periodClass: json["Class"] == null ? null : Class.fromJson(json["Class"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "day_of_week": dayOfWeek,
    "period_number": periodNumber,
    "subject_id": subjectId,
    "staff_id": staffId,
    "createdAt": createdAt?.toIso8601String(),
    "User": user?.toJson(),
    "Subject": subject?.toJson(),
    "Class": periodClass?.toJson(),
  };
}

class Class {
  int? id;
  String? classname;

  Class({this.id, this.classname});

  factory Class.fromJson(Map<String, dynamic> json) =>
      Class(id: json["id"], classname: json["classname"]);

  Map<String, dynamic> toJson() => {"id": id, "classname": classname};
}

class Subject {
  int? id;
  String? subjectName;

  Subject({this.id, this.subjectName});

  factory Subject.fromJson(Map<String, dynamic> json) =>
      Subject(id: json["id"], subjectName: json["subject_name"]);

  Map<String, dynamic> toJson() => {"id": id, "subject_name": subjectName};
}

class User {
  int? id;
  String? name;

  User({this.id, this.name});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}
