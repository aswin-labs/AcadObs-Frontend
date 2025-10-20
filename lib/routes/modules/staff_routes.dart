import 'package:acadobs/features/achievements/presentaion/screens/achievement_details_screen.dart';
import 'package:acadobs/features/achievements/presentaion/screens/add_achievements_screen.dart';
import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/features/parents/presentation/screens/payment_detail_screen.dart';
import 'package:acadobs/features/students/acheivement/achievement_edit_screen.dart';

import 'package:acadobs/features/students/presentation/widgets/time_table_day_tab.dart';
import 'package:acadobs/features/teacher/data/models/note_model.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/screens/student_leaves_screen.dart';
import 'package:acadobs/features/teacher/presentation/notes/screens/note_details_screen.dart';
import 'package:acadobs/features/teacher/presentation/notes/screens/note_listing_screen.dart';
import 'package:acadobs/features/events/data/models/event_model.dart';
import 'package:acadobs/features/events/presentation/screens/event_detail_screen.dart';
import 'package:acadobs/features/events/presentation/screens/event_list_screen.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homework/presentation/screens/edit_home_work_screen.dart';
import 'package:acadobs/features/homework/presentation/screens/homework_details_screen.dart';
import 'package:acadobs/features/homework/presentation/screens/homework_ranking_screen.dart';
import 'package:acadobs/features/homework/presentation/screens/homeworks_home_screen.dart';
import 'package:acadobs/features/news/presentation/screens/news_full_screen.dart';
import 'package:acadobs/features/news/presentation/screens/news_screen_details.dart';
import 'package:acadobs/features/notices/presentation/screens/notice_details_screen.dart';
import 'package:acadobs/features/notices/presentation/screens/notice_screen.dart';
import 'package:acadobs/features/parents/data/models/notice_model.dart';
import 'package:acadobs/features/students/acheivement/achievement_listing_screen.dart';
import 'package:acadobs/features/students/acheivement/achievement_model.dart';
import 'package:acadobs/features/students/presentation/screens/student_detail_screen.dart';
import 'package:acadobs/features/students/presentation/screens/students_listing_screen.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_model.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_upload_model.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:acadobs/features/marks/data/models/marks_model.dart';
import 'package:acadobs/features/marks/data/models/marks_upload_model.dart';
import 'package:acadobs/features/news/data/models/news_model.dart';
import 'package:acadobs/features/teacher/data/models/staff_duty_model.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/attendance_details_screen.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/attendance_taking_screen.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/edit_attendance_screen.dart';
import 'package:acadobs/features/chats/presentation/screens/add_teacher_note_screen.dart';
import 'package:acadobs/features/teacher/presentation/duties/screens/duty_detail_screen.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/screens/leave_request_detail_screen.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/screens/teacher_leave_request_home_screen.dart';
import 'package:acadobs/features/marks/presentation/screens/add_student_marks_screen.dart';
import 'package:acadobs/features/marks/presentation/screens/edit_marks_screen.dart';
import 'package:acadobs/features/marks/presentation/screens/marks_detail_screen.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:go_router/go_router.dart';

List<GoRoute> staffRoutes = [
  // Duties
  GoRoute(
    path: '/dutyDetail',
    name: RouteConstants.dutyDetail,
    builder: (context, state) {
      final Request staffDuty = state.extra as Request;
      return DutyDetailScreen(staffDuty: staffDuty);
    },
  ),

  // Attendance
  GoRoute(
    path: '/attendanceTaking',
    name: RouteConstants.attendanceTaking,
    builder: (context, state) {
      final AttendanceUploadModel attendance =
          state.extra as AttendanceUploadModel;
      return AttendanceTakingScreen(attendance: attendance);
    },
  ),
  GoRoute(
    path: '/attendanceDetails',
    name: RouteConstants.attendanceDetails,
    builder: (context, state) {
      final attendance = state.extra as AttendanceModel;
      return AttendanceDetailsScreen(attendance: attendance);
    },
  ),
  GoRoute(
    path: '/editAttendance',
    name: RouteConstants.editAttendance,
    builder: (context, state) {
      final attendance = state.extra as AttendanceModel;
      return EditAttendanceScreen(attendance: attendance);
    },
  ),

  // Students
  GoRoute(
    path: '/studentListing',
    name: RouteConstants.studentListing,
    builder: (context, state) => StudentsListingScreen(),
  ),
  GoRoute(
    path: '/studentDetails',
    name: RouteConstants.studentDetails,
    builder: (context, state) {
      final studentDetailParams = state.extra as StudentDetailParameters;

      return StudentDetailScreen(
        studentId: studentDetailParams.studentId,
        forParent: studentDetailParams.forParent,
      );
    },
  ),

  // Leave requests
  GoRoute(
    path: '/staffLeaveRequestHome',
    name: RouteConstants.staffLeaveRequestHome,
    builder: (context, state) => TeacherLeaveRequestHomeScreen(),
  ),
  GoRoute(
    path: '/staffLeaveRequestDetails',
    name: RouteConstants.staffLeaveRequestDetails,
    builder: (context, state) {
      LeaveModel leave = state.extra as LeaveModel;
      return LeaveRequestDetailScreen(leave: leave);
    },
  ),

  // Homeworks
  GoRoute(
    path: '/homeworks',
    name: RouteConstants.homeworks,
    builder: (context, state) => HomeworksHomeScreen(),
  ),
  GoRoute(
    path: '/homeworkDetails',
    name: RouteConstants.homeworkDetails,
    builder: (context, state) {
      HomeworkModel homework = state.extra as HomeworkModel;
      return HomeworkDetailsScreen(homework: homework);
    },
  ),
  GoRoute(
    path: '/edithomework',
    name: RouteConstants.editHomeWork,
    builder: (context, state) {
      HomeworkModel homework = state.extra as HomeworkModel;
      return EditHomeWorkScreen(homework: homework);
    },
  ),

  GoRoute(
    path: '/homeworkRankingScreen',
    name: RouteConstants.homeworkRankingScreen,
    builder: (context, state) {
      HomeworkModel homework = state.extra as HomeworkModel;
      return HomeworkRankingScreen(homework: homework);
    },
  ),

  //notice
  GoRoute(
    path: '/noticedetails',
    name: RouteConstants.noticedetails,
    builder: (context, state) {
      final Notices noticedetail = state.extra as Notices;
      return NoticeDetailsScreen(notices: noticedetail);
    },
  ),

  //noticedetails
  GoRoute(
    path: '/noticeListscreen',
    name: RouteConstants.noticeListscreen,
    builder: (context, state) {
      // final Notices noticedetail = state.extra as Notices;
      return NoticeScreen();
    },
  ),

  //events
  GoRoute(
    path: '/eventdetails',
    name: RouteConstants.eventlistdetails,
    builder: (context, state) {
      final Events eventdetail = state.extra as Events;
      return EventDetailScreen(events: eventdetail);
    },
  ),

  GoRoute(
    path: '/eventListscreen',
    name: RouteConstants.eventListscreen,
    builder: (context, state) {
      final forStaff = state.extra as bool;
      return EventListScreen(forStaff: forStaff);
    },
  ),

  //add student Marks screen
  GoRoute(
    path: '/addStudentMarks',
    name: RouteConstants.addStudentMarks,
    builder: (context, state) {
      final MarksUploadModel marks = state.extra as MarksUploadModel;
      return AddStudentMarksScreen(marks: marks);
    },
  ),

  //news details screen
  GoRoute(
    path: '/newsdetailscreen',
    name: RouteConstants.newsDetailsScreen,
    builder: (context, state) {
      final forStaff = state.extra as bool;
      return NewsDetailsScreen(forStaff: forStaff);
    },
  ),

  GoRoute(
    path: '/newsScreen',
    name: RouteConstants.newsScreen,
    builder: (context, state) {
      final News news = state.extra as News;
      return NewsScreenDetails(newModel: news);
    },
  ),
  //marks details screen
  GoRoute(
    path: '/marksDetails',
    name: RouteConstants.marksDetails,
    builder: (context, state) {
      final MarksModel marks = state.extra as MarksModel;
      return MarksDetailScreen(marks: marks);
    },
  ),

  //marks edit screen
  GoRoute(
    path: '/marksEdit',
    name: RouteConstants.marksEdit,
    builder: (context, state) {
      final MarksModel marks = state.extra as MarksModel;
      return EditMarksScreen(marks: marks);
    },
  ),

  // add achievements screen
  GoRoute(
    path: '/addAchievements',
    name: RouteConstants.addAchievements,
    builder: (context, state) {
      return AddAchievementsScreen();
    },
  ),

  GoRoute(
    path: '/getAchievements',
    name: RouteConstants.getAchievement,
    builder: (context, state) {
      return AchievementListingScreen();
    },
  ),

  //add Note screen
  GoRoute(
    path: '/addteachernotesection',
    name: RouteConstants.addTeacherNoteSection,
    builder: (context, state) {
      return AddTeacherNoteScreen();
    },
  ),

  //note listing screen
  GoRoute(
    path: '/noteListingScreen',
    name: RouteConstants.noteListingScreen,
    builder: (context, state) {
      return NoteListingScreen();
    },
  ),

  //note detail screen
  GoRoute(
    path: '/noteDetailScreen',
    name: RouteConstants.noteDetailScreen,
    builder: (context, state) {
      final Note noteModel = state.extra as Note;
      return NoteDetailsScreen(note: noteModel);
    },
  ),

  //achievement detail screen
  GoRoute(
    path: '/achievementdetatilscreen',
    name: RouteConstants.achievementDetailsScreen,
    builder: (context, state) {
      final AchievementModel achievementModel = state.extra as AchievementModel;
      return AchievementDetailsScreen(achievementModel: achievementModel);
    },
  ),

  //achievement edit detail screen
  GoRoute(
    path: '/achievementEditScreen',
    name: RouteConstants.editAchievement,
    builder: (context, state) {
      final AchievementModel achievementModel = state.extra as AchievementModel;
      return AchievementEditScreen(achievement: achievementModel);
    },
  ),

  //payment detail page
  GoRoute(
    path: '/paymentdetailScreen',
    name: RouteConstants.paymentDetailScreen,
    builder: (context, state) {
      final Payment payment = state.extra as Payment;
      return PaymentDetailScreen(payment: payment);
    },
  ),

  //time table day tab
  GoRoute(
    path: '/timetabledaytab',
    name: RouteConstants.timeTableDayTab,
    builder: (context, state) {
      final studentId = state.extra as int;
      return TimeTableDayTab(studentId: studentId);
    },
  ),

  //student leave request view for teacher
  GoRoute(
    path: '/studentLeaveLetter',
    name: RouteConstants.studentLeaveLetter,
    builder: (context, state) {
      return StudentLeavesScreen();
    },
  ),
];

class StudentDetailParameters {
  final int studentId;
  final bool forParent;
  StudentDetailParameters({required this.forParent, required this.studentId});
}
