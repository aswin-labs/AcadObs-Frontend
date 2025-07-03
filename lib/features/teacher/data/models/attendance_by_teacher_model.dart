
import 'dart:convert';

AttendanceByTeacher attendanceByTeacherFromJson(String str) => AttendanceByTeacher.fromJson(json.decode(str));

class AttendanceByTeacher {
    int id;
    int teacherId;
    int schoolId;
    int classId;
    String? subjectId;
    int period;
    DateTime date;
    bool trash;
    DateTime createdAt;
    DateTime updatedAt;
    List<AttendanceMarked> attendanceMarkeds;
    ClassDetails classDetails;
    int? subject;

    AttendanceByTeacher({
        required this.id,
        required this.teacherId,
        required this.schoolId,
        required this.classId,
        this.subjectId,
        required this.period,
        required this.date,
        required this.trash,
        required this.createdAt,
        required this.updatedAt,
        required this.attendanceMarkeds,
        required this.classDetails,
        this.subject,
    });

    factory AttendanceByTeacher.fromJson(Map<String, dynamic> json) => AttendanceByTeacher(
        id: json["id"],
        teacherId: json["teacher_id"],
        schoolId: json["school_id"],
        classId: json["class_id"],
        subjectId: json["subject_id"],
        period: json["period"],
        date: DateTime.parse(json["date"]),
        trash: json["trash"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        attendanceMarkeds: List<AttendanceMarked>.from(json["AttendanceMarkeds"].map((x) => AttendanceMarked.fromJson(x))),
        classDetails: ClassDetails.fromJson(json["Class"]),
        subject: json["Subject"],
    );
}

class AttendanceMarked {
    int id;
    String status;
    String? remarks;
    Student student;

    AttendanceMarked({
        required this.id,
        required this.status,
        this.remarks,
        required this.student,
    });

    factory AttendanceMarked.fromJson(Map<String, dynamic> json) => AttendanceMarked(
        id: json["id"],
        status: json["status"],
        remarks: json["remarks"],
        student: Student.fromJson(json["Student"]),
    );
}

class Student {
    int id;
    String fullName;
    String? image;
    int? rollNumber;

    Student({
        required this.id,
        required this.fullName,
        this.image,
        this.rollNumber
    });

    factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json["id"],
        fullName: json["full_name"],
        image: json["image"],
        rollNumber: json["roll_number"],
    );
}

class ClassDetails {
    int id;
    String classname;

    ClassDetails({
        required this.id,
        required this.classname,
    });

    factory ClassDetails.fromJson(Map<String, dynamic> json) => ClassDetails(
        id: json["id"],
        classname: json["classname"],
    );

}
