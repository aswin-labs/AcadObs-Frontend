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
  static const String createAcheivement = "/staff/achievements";
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
  static const String homeworkRanking = "/staff/bulkUpdateHomeworkAssignments/";
  static const String fetchHomeworksByStudentIdForStaff = "/staff/getHomeworkByStudentId";


  //notices
  static const String fetchLatestNotices = "/staff/getLatestNotices";

  //events
  static const String fetchLatestEventsStaff = "/staff/getLatestEvents";

  //news
  static const String fetchLatestNews = "/staff/getLatestNews";

  // marks
  static const String marks = "/staff/internalmarks";
  static const String marksAddedByTeacher =
      "/staff/getInternalMarkByRecordedBy";
  static const String marksBulkUpdate = "/staff/bulkUpdateMarks";
  static const String studentMarks = "/staff/getInternalMarkByStudentId";

  //GUARDIAN
  static const String fetchLatestEventsGuardian = "/guardian/getLatestEvents";
  static const String fetchLatestNewsGuardian = "/guardian/getLatestNews";
  static const String fetchHomeworksByStudentIdForGuardian = "/guardian/getHomeworkByStudentId";
  static const String studentMarksForParent = "/guardian/getInternalMarkByStudentId";
  static const String studentLeaveRequest = "/guardian/leaveRequestByStudentId";
  

}
