import 'dart:convert';

AttendanceRecordedData attendanceRecordedDataFromJson(String str) => AttendanceRecordedData.fromJson(json.decode(str));

class AttendanceRecordedData {
    String status;
    Attendance attendance;

    AttendanceRecordedData({
        required this.status,
        required this.attendance,
    });

    factory AttendanceRecordedData.fromJson(Map<String, dynamic> json) => AttendanceRecordedData(
        status: json["status"],
        attendance: Attendance.fromJson(json["attendance"]),
    );
}

class Attendance {
    int id;
    int period;
    DateTime date;
    int classId;
    int? subjectId;
    User user;
    String? subject;

    Attendance({
        required this.id,
        required this.period,
        required this.date,
        required this.classId,
        this.subjectId,
        required this.user,
        this.subject,
    });

    factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
        id: json["id"],
        period: json["period"],
        date: DateTime.parse(json["date"]),
        classId: json["class_id"],
        subjectId: json["subject_id"],
        user: User.fromJson(json["User"]),
        subject: json["Subject"],
    );
}

class User {
    int id;
    String name;
    String role;

    User({
        required this.id,
        required this.name,
        required this.role,
    });

    factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        role: json["role"],
    );
}
