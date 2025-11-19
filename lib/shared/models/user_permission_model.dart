class UserPermissionModel {
    int id;
    int userId;
    bool homeworks;
    bool attendance;
    bool timetable;
    bool marks;
    bool parentNotes;
    bool achievements;
    bool studentLeaveRequest;
    bool leaveRequest;
    bool chats;
    bool payments;
    bool reports;
    bool students;
    DateTime createdAt;
    DateTime updatedAt;

    UserPermissionModel({
        required this.id,
        required this.userId,
        required this.homeworks,
        required this.attendance,
        required this.timetable,
        required this.marks,
        required this.parentNotes,
        required this.achievements,
        required this.studentLeaveRequest,
        required this.leaveRequest,
        required this.chats,
        required this.payments,
        required this.reports,
        required this.students,
        required this.createdAt,
        required this.updatedAt,
    });

    factory UserPermissionModel.fromJson(Map<String, dynamic> json) => UserPermissionModel(
        id: json["id"],
        userId: json["user_id"],
        homeworks: json["homeworks"],
        attendance: json["attendance"],
        timetable: json["timetable"],
        marks: json["marks"],
        parentNotes: json["parent_notes"],
        achievements: json["achievements"],
        studentLeaveRequest: json["student_leave_request"],
        leaveRequest: json["leave_request"],
        chats: json["chats"],
        payments: json["payments"],
        reports: json["reports"],
        students: json["students"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "homeworks": homeworks,
        "attendance": attendance,
        "timetable": timetable,
        "marks": marks,
        "parent_notes": parentNotes,
        "achievements": achievements,
        "student_leave_request": studentLeaveRequest,
        "leave_request": leaveRequest,
        "chats": chats,
        "payments": payments,
        "reports": reports,
        "students": students,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
    };
}