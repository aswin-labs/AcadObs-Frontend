/// API Endpoints (relative paths only)
class ApiEndpoints {
  // SUPER ADMIN
  static const String schools = "/superadmin/schools";
  static const String classes = "/superadmin/classes";
  static const String subjects = "/superadmin/subjects";

  // LOGIN
  static const String login = "/public/login";

  // STAFF
  static const String classesByYear = "/staff/getClassesByYear";
  static const String students = "/staff/students";
  static const String studentsByClassId = "/staff/getStudentsByClassId";
  static const String createAcheivement = "/staff/achievements";
  static const String achievementByStudentId = "/staff/achievementByStudentId";
  static const String studentLeaveRequestStaff =
      "/staff/getLeaveRequestByStudentId";
  static const String createParentNote = "/staff/parentNotes";
  static const String getLatestNotes = "/staff/parentNotes";
  static const String deleteNote = "/staff/parentNotes";

  // duties
  static const String staffDuties = "/staff/duties";
  static const String updateDutyStatus = "/staff/updateAssignedDuty";

  // attendance
  static const String attendance = "/staff/attendance";
  static const String attendanceByTeacher = "/staff/getAttendanceByTeacher";
  static const String attendanceByClassIdAndDate =
      "/staff/getAttendanceByclassIdAndDate";
  static const String editBulkAttendance = "/staff/bulkUpdateAttendanceById";
  static const String attendanceByDate = "/staff/getStudentAttendanceByDate/";

  // leave request
  static const String staffLeaveRequest = "/staff/leaveRequest";

  // homeworks
  static const String homeworks = "/staff/homeworks";
  static const String homeworkByTeacher = "/staff/getHomeworkByTeacher";
  static const String homeworkRanking = "/staff/bulkUpdateHomeworkAssignments/";
  static const String fetchHomeworksByStudentIdForStaff =
      "/staff/getHomeworkByStudentId";

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

  //Achievement
  static const String getAllAchievement = "/staff/allAchievements";
  static const String deleteAchievement = "/staff/achievements";
  static const String achievements = "/staff/achievements";

  //GUARDIAN
  static const String fetchLatestEventsGuardian = "/guardian/getLatestEvents";
  static const String fetchLatestNewsGuardian = "/guardian/getLatestNews";
  static const String fetchHomeworksByStudentIdForGuardian =
      "/guardian/getHomeworkByStudentId";
  static const String studentMarksForParent =
      "/guardian/getInternalMarkByStudentId";
  static const String studentLeaveRequest = "/guardian/leaveRequest";
  static const String achievementByGuardian =
      "/guardian/achievementByStudentId";
  static const String schoolsByGuardian = "/guardian/getSchoolsByUser";
  static const String studentsUnderGuardianBySchoolId =
      "/guardian/getStudentsUnderGuardianBySchoolId";

  static const String studentPayment = "/guardian/getPaymentbyStudentId";
}
