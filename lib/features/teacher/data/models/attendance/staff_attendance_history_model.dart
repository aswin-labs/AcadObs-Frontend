class StaffAttendanceHistoryResponse {
  final int totalContent;
  final int totalPages;
  final int currentPage;
  final List<StaffAttendanceHistoryItem> data;

  StaffAttendanceHistoryResponse({
    required this.totalContent,
    required this.totalPages,
    required this.currentPage,
    required this.data,
  });

  factory StaffAttendanceHistoryResponse.fromJson(Map<String, dynamic> json) {
    return StaffAttendanceHistoryResponse(
      totalContent: json["totalcontent"] is int
          ? json["totalcontent"]
          : int.tryParse(json["totalcontent"]?.toString() ?? '0') ?? 0,
      totalPages: json["totalPages"] is int
          ? json["totalPages"]
          : int.tryParse(json["totalPages"]?.toString() ?? '1') ?? 1,
      currentPage: json["currentPage"] is int
          ? json["currentPage"]
          : int.tryParse(json["currentPage"]?.toString() ?? '1') ?? 1,
      data: json["data"] != null
          ? List<StaffAttendanceHistoryItem>.from(
              (json["data"] as List)
                  .map((x) => StaffAttendanceHistoryItem.fromJson(x)),
            )
          : [],
    );
  }
}

class StaffAttendanceHistoryItem {
  final int? id;
  final int? schoolId;
  final int? staffId;
  final String? date;
  final String? status;
  final String? checkInTime;
  final String? checkOutTime;
  final String? totalHours;
  final String? markedMethod;
  final String? remarks;
  final dynamic markedDeviceId;

  StaffAttendanceHistoryItem({
    this.id,
    this.schoolId,
    this.staffId,
    this.date,
    this.status,
    this.checkInTime,
    this.checkOutTime,
    this.totalHours,
    this.markedMethod,
    this.remarks,
    this.markedDeviceId,
  });

  factory StaffAttendanceHistoryItem.fromJson(Map<String, dynamic> json) {
    return StaffAttendanceHistoryItem(
      id: json["id"],
      schoolId: json["school_id"],
      staffId: json["staff_id"],
      date: json["date"],
      status: json["status"],
      checkInTime: json["check_in_time"],
      checkOutTime: json["check_out_time"],
      totalHours: json["total_hours"]?.toString(),
      markedMethod: json["marked_method"],
      remarks: json["remarks"],
      markedDeviceId: json["marked_device_id"],
    );
  }
}
