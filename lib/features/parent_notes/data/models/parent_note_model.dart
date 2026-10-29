import 'dart:convert';

ParentNoteModel parentNoteModelFromJson(String str) =>
    ParentNoteModel.fromJson(json.decode(str));

String parentNoteModelToJson(ParentNoteModel data) =>
    json.encode(data.toJson());

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}

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
  bool get isSeenByStudent =>
      parentNoteStudents != null &&
      parentNoteStudents!.isNotEmpty &&
      (parentNoteStudents!.first.isSeen ?? false);

  factory ParentNoteModel.fromJson(Map<String, dynamic> json) =>
      ParentNoteModel(
        id: _parseInt(json["id"]),
        schoolId: _parseInt(json["school_id"]),
        noteTitle: json["note_title"]?.toString(),
        noteContent: json["note_content"]?.toString(),
        noteAttachment: json["note_attachment"]?.toString(),
        recordedBy: _parseInt(json["recorded_by"]),
        trash: json["trash"] == true || json["trash"] == 1,
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
        id: _parseInt(json["id"]),
        studentId: _parseInt(json["student_id"]),
        isSeen: json["is_seen"] == true || json["is_seen"] == 1,
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
        id: _parseInt(json["id"]),
        fullName: json["full_name"]?.toString(),
        regNo: json["reg_no"]?.toString(),
        classId: _parseInt(json["class_id"]),
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

  factory ParentNoteListResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json["notes"] ?? json["data"];
    return ParentNoteListResponse(
      totalContent: _parseInt(
        json["totalcontent"] ?? json["totalContent"] ?? json["total_content"],
      ),
      totalPages: _parseInt(json["totalPages"] ?? json["total_pages"]),
      currentPage: _parseInt(
        json["currentPage"] ?? json["current_page"] ?? json["pageNo"],
      ),
      notes:
          rawList is List
              ? rawList
                  .whereType<Map<String, dynamic>>()
                  .map((e) => ParentNoteModel.fromJson(e))
                  .toList()
              : [],
    );
  }
}
