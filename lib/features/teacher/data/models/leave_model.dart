import 'dart:convert';

import 'package:acadobs/shared/models/user_model.dart';

LeaveModel leaveModelFromJson(String str) =>
    LeaveModel.fromJson(json.decode(str));

class LeaveModel {
  int id;
  int schoolId;
  int? userId;
  int? studentId;
  String? approvedBy;
  String? role;
  String reason;
  String leaveType;
  String? leaveDuration;
  String fromDate;
  String toDate;
  String? status;
  String? adminRemarks;
  String? attachment;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;
  UserModel? user;

  LeaveModel({
    required this.id,
    required this.schoolId,
    this.userId,
    this.studentId,
    this.approvedBy,
    this.role,
    required this.reason,
    required this.leaveType,
    this.leaveDuration,
    required this.fromDate,
    required this.toDate,
    this.status,
    this.adminRemarks,
    this.attachment,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
    id: json["id"] ?? 0,
    schoolId: json["school_id"] ?? 0,
    userId: json["user_id"],
    studentId: json["student_id"],
    approvedBy: json["approved_by"],
    role: json["role"],
    reason: json["reason"] ?? '',
    leaveType: json["leave_type"] ?? '',
    leaveDuration: json["leave_duration"],
    fromDate: json["from_date"] ?? '',
    toDate: json["to_date"] ?? '',
    status: json["status"] ?? '',
    adminRemarks: json["admin_remarks"],
    attachment: json["attachment"],
    trash: json["trash"],
    // createdAt:
    //     json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    createdAt:
        json["createdAt"] != null ? DateTime.parse(json["createdAt"]) : null,
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    user: json["User"] == null ? null : UserModel.fromJson(json["User"]),
  );
}
