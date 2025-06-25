import 'dart:convert';

UpdatedDutyResponse updatedDutyResponseFromJson(String str) =>
    UpdatedDutyResponse.fromJson(json.decode(str));

class UpdatedDutyResponse {
  int? id;
  int? staffId;
  int? dutyId;
  String? status;
  String? remarks;
  dynamic solvedFile;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;

  UpdatedDutyResponse({
    this.id,
    this.staffId,
    this.dutyId,
    this.status,
    this.remarks,
    this.solvedFile,
    this.trash,
    this.createdAt,
    this.updatedAt,
  });

  factory UpdatedDutyResponse.fromJson(
    Map<String, dynamic> json,
  ) => UpdatedDutyResponse(
    id: json["id"],
    staffId: json["staff_id"],
    dutyId: json["duty_id"],
    status: json["status"],
    remarks: json["remarks"],
    solvedFile: json["solved_file"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );
}
