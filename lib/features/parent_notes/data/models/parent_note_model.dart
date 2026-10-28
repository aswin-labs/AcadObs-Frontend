import 'dart:convert';

ParentNoteModel parentNoteModelFromJson(String str) =>
    ParentNoteModel.fromJson(json.decode(str));

String parentNoteModelToJson(ParentNoteModel data) =>
    json.encode(data.toJson());

class ParentNoteModel {
  final int? id;
  final int? schoolId;
  final String? noteTitle;
  final String? noteContent;
  final String? noteAttachment;
  final int? recordedBy;
  final bool? trash;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ParentNoteStudentModel>? parentNoteStudents;

  ParentNoteModel({
    this.id,
    this.schoolId,
    this.noteTitle,
    this.noteContent,
    this.noteAttachment,
    this.recordedBy,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.parentNoteStudents,
  });

  int get studentCount => parentNoteStudents?.length ?? 0;
  int get seenCount =>
      parentNoteStudents?.where((s) => s.isSeen == true).length ?? 0;

  factory ParentNoteModel.fromJson(Map<String, dynamic> json) =>
      ParentNoteModel(
        id: json["id"],
        schoolId: json["school_id"],
        noteTitle: json["note_title"],
        noteContent: json["note_content"],
        noteAttachment: json["note_attachment"]?.toString(),
        recordedBy: json["recorded_by"],
        trash: json["trash"],
        createdAt:
            json["createdAt"] == null
                ? null
                : DateTime.tryParse(json["createdAt"].toString()),
        updatedAt:
            json["updatedAt"] == null
                ? null
                : DateTime.tryParse(json["updatedAt"].toString()),
        parentNoteStudents:
            json["ParentNoteStudents"] is List
                ? (json["ParentNoteStudents"] as List)
                    .map((e) => ParentNoteStudentModel.fromJson(e))
                    .toList()
                : null,
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
    if (parentNoteStudents != null)
      "ParentNoteStudents": parentNoteStudents!.map((e) => e.toJson()).toList(),
  };
}

class ParentNoteStudentModel {
  final int? id;
  final int? studentId;
  final bool? isSeen;
  final ParentNoteStudentInfoModel? student;

  ParentNoteStudentModel({this.id, this.studentId, this.isSeen, this.student});

  factory ParentNoteStudentModel.fromJson(Map<String, dynamic> json) =>
      ParentNoteStudentModel(
        id: json["id"],
        studentId: json["student_id"],
        isSeen: json["is_seen"] ?? false,
        student:
            json["Student"] is Map<String, dynamic>
                ? ParentNoteStudentInfoModel.fromJson(json["Student"])
                : null,
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "student_id": studentId,
    "is_seen": isSeen,
    if (student != null) "Student": student!.toJson(),
  };
}

class ParentNoteStudentInfoModel {
  final int? id;
  final String? fullName;
  final String? regNo;
  final int? classId;

  ParentNoteStudentInfoModel({
    this.id,
    this.fullName,
    this.regNo,
    this.classId,
  });

  factory ParentNoteStudentInfoModel.fromJson(Map<String, dynamic> json) =>
      ParentNoteStudentInfoModel(
        id: json["id"],
        fullName: json["full_name"],
        regNo: json["reg_no"]?.toString(),
        classId: json["class_id"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "reg_no": regNo,
    "class_id": classId,
  };
}

class ParentNoteListResponse {
  final int? totalContent;
  final int? totalPages;
  final int? currentPage;
  final List<ParentNoteModel> notes;

  ParentNoteListResponse({
    this.totalContent,
    this.totalPages,
    this.currentPage,
    this.notes = const [],
  });

  factory ParentNoteListResponse.fromJson(Map<String, dynamic> json) =>
      ParentNoteListResponse(
        totalContent: json["totalcontent"] ?? json["totalContent"],
        totalPages: json["totalPages"],
        currentPage: json["currentPage"],
        notes:
            json["notes"] is List
                ? (json["notes"] as List)
                    .map((e) => ParentNoteModel.fromJson(e))
                    .toList()
                : [],
      );
}
