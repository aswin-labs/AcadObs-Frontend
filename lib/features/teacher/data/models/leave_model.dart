import 'dart:convert';

import 'package:acadobs/features/students/data/models/student_model.dart';
import 'package:acadobs/shared/models/user_model.dart';

LeaveModel leaveModelFromJson(String str) =>
    LeaveModel.fromJson(json.decode(str));

class LeaveModel {
  bool? forStudentLeavePermission;
  int? id;
  int? schoolId;
  int? userId;
  dynamic studentId;
  dynamic approvedBy;
  String? role;
  String? reason;
  String? leaveType;
  String? leaveDuration;
  DateTime? fromDate;
  DateTime? toDate;
  String? status;
  dynamic adminRemarks;
  dynamic attachment;
  bool? trash;
  DateTime? createdAt;
  DateTime? updatedAt;
  UserModel? user;
  StudentModel? student;

  LeaveModel({
    this.id,
    this.schoolId,
    this.userId,
    this.studentId,
    this.approvedBy,
    this.role,
    this.reason,
    this.leaveType,
    this.leaveDuration,
    this.fromDate,
    this.toDate,
    this.status,
    this.adminRemarks,
    this.attachment,
    this.trash,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.student,
    this.forStudentLeavePermission = false,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
    id: json["id"],
    schoolId: json["school_id"],
    userId: json["user_id"],
    studentId: json["student_id"],
    approvedBy: json["approved_by"],
    role: json["role"],
    reason: json["reason"],
    leaveType: json["leave_type"],
    leaveDuration: json["leave_duration"],
    fromDate:
        json["from_date"] == null ? null : DateTime.parse(json["from_date"]),
    toDate: json["to_date"] == null ? null : DateTime.parse(json["to_date"]),
    status: json["status"],
    adminRemarks: json["admin_remarks"],
    attachment: json["attachment"],
    trash: json["trash"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    user: json["User"] == null ? null : UserModel.fromJson(json["User"]),
    student:
        json["Student"] == null ? null : StudentModel.fromJson(json["Student"]),
  );
}
