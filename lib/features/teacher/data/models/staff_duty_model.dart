import 'dart:convert';

StaffDuty staffDutyFromJson(String str) => StaffDuty.fromJson(json.decode(str));

class StaffDuty {
  int id;
  String remarks;
  String status;
  dynamic solvedFile;
  Duty duty;

  StaffDuty({
    required this.id,
    required this.remarks,
    required this.status,
    required this.solvedFile,
    required this.duty,
  });

  factory StaffDuty.fromJson(Map<String, dynamic> json) => StaffDuty(
    id: json["id"],
    remarks: json["remarks"],
    status: json["status"],
    solvedFile: json["solved_file"],
    duty: Duty.fromJson(json["Duty"]),
  );
}

class Duty {
  int id;
  String title;
  String description;
  DateTime deadline;
  dynamic file;

  Duty({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    required this.file,
  });

  factory Duty.fromJson(Map<String, dynamic> json) => Duty(
    id: json["id"],
    title: json["title"],
    description: json["description"],
    deadline: DateTime.parse(json["deadline"]),
    file: json["file"],
  );
}
