// To parse this JSON data, do
//
//     final leaveModel = leaveModelFromJson(jsonString);

import 'dart:convert';

LeaveModel leaveModelFromJson(String str) => LeaveModel.fromJson(json.decode(str));

String leaveModelToJson(LeaveModel data) => json.encode(data.toJson());

class LeaveModel {
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
    User? user;

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
        fromDate: json["from_date"] == null ? null : DateTime.parse(json["from_date"]),
        toDate: json["to_date"] == null ? null : DateTime.parse(json["to_date"]),
        status: json["status"],
        adminRemarks: json["admin_remarks"],
        attachment: json["attachment"],
        trash: json["trash"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        user: json["User"] == null ? null : User.fromJson(json["User"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "school_id": schoolId,
        "user_id": userId,
        "student_id": studentId,
        "approved_by": approvedBy,
        "role": role,
        "reason": reason,
        "leave_type": leaveType,
        "leave_duration": leaveDuration,
        "from_date": "${fromDate!.year.toString().padLeft(4, '0')}-${fromDate!.month.toString().padLeft(2, '0')}-${fromDate!.day.toString().padLeft(2, '0')}",
        "to_date": "${toDate!.year.toString().padLeft(4, '0')}-${toDate!.month.toString().padLeft(2, '0')}-${toDate!.day.toString().padLeft(2, '0')}",
        "status": status,
        "admin_remarks": adminRemarks,
        "attachment": attachment,
        "trash": trash,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "User": user?.toJson(),
    };
}

class User {
    int? id;
    String? name;
    String? email;
    String? phone;

    User({
        this.id,
        this.name,
        this.email,
        this.phone,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        phone: json["phone"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "phone": phone,
    };
}
