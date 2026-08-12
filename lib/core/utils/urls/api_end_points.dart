/// API Endpoints (relative paths only)
class ApiEndpoints {
  // LOGIN - LOGOUT
  static const String login = "/public/login";
  static const String logout = "/public/logout";

  // Refresh token
  static const String refreshToken = "/public/refresh-token";

  // PROFILE SETTINGS
  static const String staffChangePassword = "/teacher/changePassword";
  static const String guardianChangePassword = "/guardian/changePassword";
  static const String guardianProfile = "/guardian/getProfileDetails";
  static const String updateGuardianProfile = "/guardian/updateProfileDetails";
  static const String updateProfilePhotoGuardian = "/guardian/updateDp";
  static const String updateProfilePhotoStaff = "/teacher/updateDp";

  //*****************STAFF*********************

  static const String classesByYear = "/teacher/getClassesByYear";
  static const String students = "/teacher/students";
  static const String guardian = "/guardian/students";
  static const String studentsByClassId = "/teacher/getStudentsByClassId";
  static const String createAcheivement = "/teacher/achievements";
  static const String achievementByStudentId =
      "/teacher/achievementByStudentId";
  static const String studentLeaveRequestStaff =
      "/teacher/getLeaveRequestByStudentId";
  static const String createParentNote = "/teacher/parentNotes";
  static const String getLatestNotes = "/teacher/parentNotes";
  static const String deleteNote = "/teacher/parentNotes";
  static const String schoolDetailsForTeacher = "/teacher/getSchoolDetails";
  static const String getMyClassMarks = "/teacher/getMyClassExamMark";
  static const String getMyClassInternalMarks =
      "/teacher/getMyClassInternalMark";
  static const String getMyClassHomeworks = "/teacher/getMyClassHomework";

  // duties
  static const String staffDuties = "/teacher/duties";
  static const String updateDutyStatus = "/teacher/updateAssignedDuty";

  // attendance
  static const String attendance = "/teacher/attendance";
  static const String attendanceByTeacher = "/teacher/getAttendanceByTeacher";
  static const String attendanceByClassIdAndDate =
      "/teacher/getAttendanceByclassIdAndDate";
  static const String editBulkAttendance = "/teacher/bulkUpdateAttendanceById";
  static const String attendanceByDateForStaff =
      "/teacher/getStudentAttendanceByDate/";

  // leave request
  static const String staffLeaveRequest = "/teacher/leaveRequest";
  static const String studentLeaveLetter =
      "/teacher/getStudentLeaveRequestsForClassTeacher";
  static const String studentLeavePermission =
      "/teacher/leaveRequestpermission";
  static const String leaveRequestNotification =
      "/teacher/getNavigationBarCounts";

  //notices
  static const String fetchLatestNotices = "/teacher/getLatestNotices";
  static const String fetchLatestNoticesGuardian = "/guardian/getLatestNotices";

  //events
  static const String fetchLatestEventsStaff = "/teacher/getLatestEvents";

  //news
  static const String fetchLatestNews = "/teacher/getLatestNews";

  // marks
  static const String marks = "/teacher/internalmarks";
  static const String checkExistingInternal = "/teacher/checkExistingInternal";
  static const String marksAddedByTeacher =
      "/teacher/getInternalMarkByRecordedBy";
  static const String termExamAddedByTeacher =
      "/teacher/getExamMarkByRecordedBy";
  static const String marksBulkUpdate = "/teacher/bulkUpdateMarks";
  static const String studentMarks = "/teacher/getInternalMarkByStudentId";
  static const String studentExamMarks = "/teacher/getExamMarkByStudentId";
  static const String termExams = "/teacher/getExams";
  static const String myMultiTeacherSubjectInternalMarks = "/teacher/myMultiTeacherSubjectInternalMarks";
  static const String getInternalMarksByIdWithSubject = "/teacher/getInternalMarksByIdWithSubject";
  static const String getClassWaiseTermMarksPdf = "/teacher/getClassWaiseTermMarksPdf";
  static const String getMissingStudentsListfromClassId = "/teacher/getMissingStudentsListfromClassId";
  static const String createNewMarksByInternalId = "/teacher/createNewMarksByInternalId";
  static const String deleteMarkById = "/teacher/deleteMarkById";

  //Achievement
  static const String getAllAchievement = "/teacher/allAchievements";
  static const String deleteAchievement = "/teacher/achievements";
  static const String achievements = "/teacher/achievements";

  static const String getAchievementsBySchoolStaff =
      "/teacher/getAchievementsBySchool";

  // teacher attendance
  static const String teacherTodayAttendance = "/teacher/todayAttendanceStatus";
  static const String teacherCheckIn = "/teacher/markSelfAttendance";
  static const String teacherCheckOut = "/teacher/markCheckOutSelfAttendance";

  static const String staffProfile = "/teacher/getProfileDetails";

  static const String singleAchievementForStaff = "/teacher/achievements";
  static const String staffPermissions = "staff/getMyPermissions";
  //  subjects
  static const String staffSubjects = "/teacher/getStaffSubjects";
  static const String subjectsAll = "/teacher/getSubjects";

  //***********************GUARDIAN*************************
  static const String fetchLatestEventsGuardian = "/guardian/getLatestEvents";
  static const String fetchLatestNewsGuardian = "/guardian/getLatestNews";
  static const String fetchHomeworksByStudentIdForGuardian =
      "/guardian/getHomeworkByStudentId";
  static const String studentMarksForParent =
      "/guardian/getInternalMarkByStudentId";
  static const String studentExamMarksForParent =
      "/guardian/getExamMarkByStudentId";
  static const String createStudentLeaveRequest = "/guardian/leaveRequest";
  static const String getStudentLeaveRequest =
      "/guardian/getLeaveRequestByStudentId";
  static const String achievementByGuardian =
      "/guardian/achievementByStudentId";
  static const String schoolsByGuardian = "/guardian/getSchoolsByUser";
  static const String studentsUnderGuardianBySchoolId =
      "/guardian/getStudentsUnderGuardianBySchoolId";

  static const String studentPayment = "/guardian/getPaymentbyStudentId";
  static const String studentInvoices = "/guardian/getInvoiceByStudentId";
  static const String studentNotices = "/guardian/getNoticeByStudentId/";
  static const String staffsBySchoolId = "/guardian/getStaffsBySchoolId";

  static const String guardianNotification = "/guardian/updateFcmToken";
  static const String singleAchievementForGuardian =
      "/guardian/getAchievementById";
  static const String getAchievementsBySchoolGuardian =
      "/guardian/getAchievementsBySchool";
  static const String attendanceByDateForGuardian =
      "/guardian/getStudentAttendanceByDate/";

  static const String updateStudentProfile = "/guardian/updateStudentProfile";

  static const String updateCredentialAndName =
      "/guardian/changeIdentifiersAndName";
  static const String uploadPaymentDetails = "/guardian/payments";

  //profile details for staff
  static const String staffProfileDetails = "/teacher/getProfileDetails";
  static const String updateStaffProfile = "/teacher/updateProfileDetails";

  //get student route for guardian
  static const String getStudentRoute = "/guardian/getRoutesForGuardian";
  static const String getRouteCount = "/guardian/getGuardianRouteCount";
  static const String routeInactive = "/guardian/routeInactive";
  static const String getStopsForParent = "/guardian/getStopsForParent";

  // guardian homework details
  static const String getHomeworkAssignmentsById =
      "/guardian/getHomeworkAssignmentsById";

  // *************************TIME TABLE******************************
  static const String getTodayTimetableForStaff =
      "/teacher/getTodayTimetableForStaff";
  static const String getAllDayTimetableForStaff =
      "/teacher/getAllDayTimetableForStaff";
  static const String getMyClassTodayTimetable =
      "/teacher/getMyClassTodayTimetable";
  static const String getMyClassAllDayTimetable =
      "/teacher/getMyClassAllDayTimetable";
  static const String getTodayTimeTableByStudentId =
      "/guardian/getTodayTimeTableByStudentId";
  static const String getAllDayTimeTableByStudentId =
      "/guardian/getAllDayTimeTableByStudentId";

  // *************************TIME TABLE END***************************

  // ************************* HOMEWORKS *****************************
  static const String homeworks = "/teacher/homeworks";
  static const String homeworkByTeacher = "/teacher/getHomeworkByTeacher";
  static const String homeworkRanking =
      "/teacher/bulkUpdateHomeworkAssignments/";
  static const String fetchHomeworksByStudentIdForStaff =
      "/teacher/getHomeworkByStudentId";
  static const String sendHomeworkRemarks = "/teacher/updateHomeworkAssignment";
  static const String myClassHomeworks = "/teacher/getMyClassHomework";

  static const String homeworksByStudentIdForGuardian =
      "/guardian/getHomeworkByStudentId";
  static const String homeworksByStudentIdForTeacher =
      "/teacher/getHomeworkByStudentId";
  static const String singleHomeworkByStudentIdForGuardian =
      "/guardian/getHomeworkByIdAndStudentId";
  static const String singleHomeworkByStudentIdForTeacher =
      "/teacher/getHomeworkByIdAndStudentId";
  static const String uploadHomeworkFileAndRemarksByGuardian =
      "/guardian/updateHomeworkAssignment";

  // ************************* HOMEWORKS END*****************************
}
