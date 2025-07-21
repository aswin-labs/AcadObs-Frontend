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
  static const String staffDuties = "/staff/duties";
  static const String updateDutyStatus = "/staff/updateAssignedDuty";
  static const String attendance = "/staff/attendance";
  static const String attendanceByTeacher = "/staff/getAttendanceByTeacher";
  static const String attendanceByClassIdAndDate =
      "/staff/getAttendanceByclassIdAndDate";
   static const String editBulkAttendance = "/staff/bulkUpdateAttendanceById";
  static const String staffLeaveRequest = "/staff/leaveRequest";
  static const String homeworks = "staff/homeworks";

  

  //notices
  static const String fetchNotices = "/schooladmin/notices";
  



}
