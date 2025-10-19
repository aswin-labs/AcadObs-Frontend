import 'package:acadobs/features/students/data/models/student_model.dart';

class GroupedLeaveRequest {
    DateTime? date;
    List<Request>? requests;

    GroupedLeaveRequest({
        this.date,
        this.requests,
    });

    factory GroupedLeaveRequest.fromJson(Map<String, dynamic> json) => GroupedLeaveRequest(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        requests: json["requests"] == null ? [] : List<Request>.from(json["requests"]!.map((x) => Request.fromJson(x))),
    );
}

class Request {
    int? id;
    int? userId;
    DateTime? fromDate;
    DateTime? toDate;
    String? status;
    DateTime? createdAt;
    StudentModel? student;

    Request({
        this.id,
        this.userId,
        this.fromDate,
        this.toDate,
        this.status,
        this.createdAt,
        this.student,
    });

    factory Request.fromJson(Map<String, dynamic> json) => Request(
        id: json["id"],
        userId: json["user_id"],
        fromDate: json["from_date"] == null ? null : DateTime.parse(json["from_date"]),
        toDate: json["to_date"] == null ? null : DateTime.parse(json["to_date"]),
        status: json["status"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        student: json["Student"] == null ? null : StudentModel.fromJson(json["Student"]),
    );

}
