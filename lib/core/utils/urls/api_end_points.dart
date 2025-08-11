/// API Endpoints (relative paths only)
class ApiEndpoints {
  // SUPER ADMIN
  static const String schools = "/superadmin/schools";
  static const String classes = "/superadmin/classes";
  static const String subjects = "/superadmin/subjects";

  // STAFF

  static const String classesByYear = "/staff/getClassesByYear";
  static const String students = "/staff/students";
  static const String studentsByClassId = "/staff/getStudentsByClassId";
  // duties
  static const String staffDuties = "/staff/duties";
  static const String updateDutyStatus = "/staff/updateAssignedDuty";

  // attendance
  static const String attendance = "/staff/attendance";
  static const String attendanceByTeacher = "/staff/getAttendanceByTeacher";
  static const String attendanceByClassIdAndDate =
      "/staff/getAttendanceByclassIdAndDate";
  static const String editBulkAttendance = "/staff/bulkUpdateAttendanceById";

  // leave request
  static const String staffLeaveRequest = "/staff/leaveRequest";
  static const String studentLeaveRequest = "/guardian/leaveRequest";

  // homeworks
  static const String homeworks = "/staff/homeworks";
  static const String homeworkByTeacher = "/staff/getHomeworkByTeacher";

  //notices
  static const String fetchNotices = "/schooladmin/notices";

  //events
  static const String fetchEvents = "/schooladmin/events";

  // marks
  static const String marks = "/staff/internalmarks";
  static const String marksAddedByTeacher =
      "/staff/getInternalMarkByRecordedBy";
  static const String marksBulkUpdate = "/staff/bulkUpdateMarks";
}
