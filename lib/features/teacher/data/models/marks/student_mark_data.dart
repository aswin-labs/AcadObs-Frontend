class StudentMarkData {
  final int studentId;
  String marksObtained;
  String attendanceStatus; // "present" or "absent"

  StudentMarkData({
    required this.studentId,
    this.marksObtained = "",
    this.attendanceStatus = "present",
  });

  // Converts the data to the exact Map format your API function needs
  Map<String, dynamic> toJson() {
    return {
      "student_id": studentId,
      // Use int.tryParse to handle empty strings gracefully, defaulting to 0
      "marks_obtained": int.tryParse(marksObtained) ?? 0, 
      "attendance_status": attendanceStatus,
    };
  }
}