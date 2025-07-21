
import 'dart:convert';

Events eventsFromJson(String str) => Events.fromJson(json.decode(str));

String eventsToJson(Events data) => json.encode(data.toJson());

class Events {
    DateTime? createdAt;
    DateTime? updatedAt;
    bool? trash;
    int? id;
    int? schoolId;
    String? title;
    DateTime? date;
    String? file;
    
    // final DateTime startDate;

    Events({
        this.createdAt,
        this.updatedAt,
        this.trash,
        this.id,
        this.schoolId,
        this.title,
        this.date,
        this.file,
        
        // required this.startDate,
    });

    factory Events.fromJson(Map<String, dynamic> json) => Events(
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        trash: json["trash"],
        id: json["id"],
        schoolId: json["school_id"],
        title: json["title"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        file: json["file"],
        // startDate: DateTime.parse(json['start_date']),
    );

    Map<String, dynamic> toJson() => {
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "trash": trash,
        "id": id,
        "school_id": schoolId,
        "title": title,
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "file": file,
    };
}
