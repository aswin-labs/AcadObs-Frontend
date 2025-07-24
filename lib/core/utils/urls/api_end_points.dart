/// API Endpoints (relative paths only)
class ApiEndpoints {
  // SUPER ADMIN
  static const String schools = "/superadmin/schools";
  static const String classes = "/superadmin/classes";
  static const String subjects = "/superadmin/subjects";

  // SCHOOL ADMIN
  static const String classesByYear = "/schooladmin/getClassesByYear";
  static const String students = "/schooladmin/students";
  static const String studentsByClassId = "/schooladmin/getStudentsByClassId";

  // STAFF
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
}
