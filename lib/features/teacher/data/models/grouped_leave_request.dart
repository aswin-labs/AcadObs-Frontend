import 'package:acadobs/features/teacher/data/models/leave_model.dart';

class GroupedLeaveRequest {
  DateTime? date;
  List<LeaveModel>? requests;

  GroupedLeaveRequest({this.date, this.requests});

  factory GroupedLeaveRequest.fromJson(Map<String, dynamic> json) =>
      GroupedLeaveRequest(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        requests:
            json["requests"] == null
                ? []
                : List<LeaveModel>.from(
                  json["requests"]!.map((x) => LeaveModel.fromJson(x)),
                ),
      );
}
