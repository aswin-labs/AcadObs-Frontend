import 'dart:convert';

Note noteFromJson(String str) => Note.fromJson(json.decode(str));

String noteToJson(Note data) => json.encode(data.toJson());

class Note {
  int? id;
  int? schoolId;
  String? noteTitle;
  String? noteContent;
  dynamic noteAttachment;
  int? recordedBy;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;

  Note({
    this.id,
    this.schoolId,
    this.noteTitle,
    this.noteContent,
    this.noteAttachment,
    this.recordedBy,
    this.trash,
    this.createdAt,
    this.updatedAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json["id"],
    schoolId: json["school_id"],
    noteTitle: json["note_title"],
    noteContent: json["note_content"],
    noteAttachment: json["note_attachment"],
    recordedBy: json["recorded_by"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "school_id": schoolId,
    "note_title": noteTitle,
    "note_content": noteContent,
    "note_attachment": noteAttachment,
    "recorded_by": recordedBy,
    "trash": trash,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}
