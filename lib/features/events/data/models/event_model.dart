import 'dart:convert';

EventModel eventsFromJson(String str) => EventModel.fromJson(json.decode(str));

class EventModel {
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? trash;
  int? id;
  int? schoolId;
  String? title;
  String? description;
  DateTime? date;
  String? file;

  EventModel({
    this.createdAt,
    this.updatedAt,
    this.trash,
    this.id,
    this.schoolId,
    this.title,
    this.description,
    this.date,
    this.file,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    trash: json["trash"],
    id: json["id"],
    schoolId: json["school_id"],
    title: json["title"],
    description: json['description'],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    file: json["file"],
  );
}
