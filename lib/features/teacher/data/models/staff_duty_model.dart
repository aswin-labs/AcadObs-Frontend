import 'dart:convert';

GroupedDuty groupedDutyFromJson(String str) =>
    GroupedDuty.fromJson(json.decode(str));

String groupedDutyToJson(GroupedDuty data) => json.encode(data.toJson());

class GroupedDuty {
  DateTime? date;
  List<Request>? requests;

  GroupedDuty({this.date, this.requests});

  factory GroupedDuty.fromJson(Map<String, dynamic> json) => GroupedDuty(
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    requests:
        json["requests"] == null
            ? []
            : List<Request>.from(
              json["requests"]!.map((x) => Request.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "date":
        "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
    "requests":
        requests == null
            ? []
            : List<dynamic>.from(requests!.map((x) => x.toJson())),
  };
}

class Request {
  int? id;
  dynamic remarks;
  String? status;
  dynamic solvedFile;
  DateTime? createdAt;
  Duty? duty;

  Request({
    this.id,
    this.remarks,
    this.status,
    this.solvedFile,
    this.createdAt,
    this.duty,
  });

  factory Request.fromJson(Map<String, dynamic> json) => Request(
    id: json["id"],
    remarks: json["remarks"],
    status: json["status"],
    solvedFile: json["solved_file"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    duty: json["Duty"] == null ? null : Duty.fromJson(json["Duty"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "remarks": remarks,
    "status": status,
    "solved_file": solvedFile,
    "createdAt": createdAt?.toIso8601String(),
    "Duty": duty?.toJson(),
  };
}

class Duty {
  int? id;
  String? title;
  String? description;
  DateTime? deadline;
  String? file;
  DateTime? startDate;
  DateTime? createdAt;

  Duty({
    this.id,
    this.title,
    this.description,
    this.deadline,
    this.file,
    this.startDate,
    this.createdAt,
  });

  factory Duty.fromJson(Map<String, dynamic> json) => Duty(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    deadline:
        json["deadline"] == null ? null : DateTime.parse(json["deadline"]),
    file: json["file"],
    startDate:
        json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "description": description,
    "deadline":
        "${deadline!.year.toString().padLeft(4, '0')}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}",
    "file": file,
    "start_date":
        "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}",
    "createdAt": createdAt?.toIso8601String(),
  };
}
