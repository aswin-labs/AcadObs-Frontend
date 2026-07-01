import 'package:acadobs/features/achievements/models/achievement_model.dart';
import 'package:acadobs/features/achievements/presentaion/screens/achievement_details_screen.dart';
import 'package:acadobs/features/achievements/presentaion/screens/achievement_edit_screen.dart';
import 'package:acadobs/features/achievements/presentaion/screens/achievement_listing_screen.dart';
import 'package:acadobs/features/achievements/presentaion/screens/add_achievements_screen.dart';
import 'package:acadobs/features/achievements/presentaion/screens/school_achievement_listing.dart';
import 'package:acadobs/features/chats/presentation/screens/add_teacher_note_screen.dart';
import 'package:acadobs/features/events/data/models/event_model.dart';
import 'package:acadobs/features/events/presentation/screens/event_detail_screen.dart';
import 'package:acadobs/features/events/presentation/screens/event_listing_screen.dart';
import 'package:acadobs/features/homework/data/models/homework_model.dart';
import 'package:acadobs/features/homework/presentation/screens/edit_home_work_screen.dart';
import 'package:acadobs/features/homework/presentation/screens/homework_details_screen.dart';
import 'package:acadobs/features/homework/presentation/screens/homework_ranking_screen.dart';
import 'package:acadobs/features/homework/presentation/screens/homeworks_home_screen.dart';
import 'package:acadobs/features/marks/data/models/marks_model.dart';
import 'package:acadobs/features/marks/data/models/marks_upload_model.dart';
import 'package:acadobs/features/marks/presentation/screens/add_student_marks_screen.dart';
import 'package:acadobs/features/marks/presentation/screens/edit_marks_screen.dart';
import 'package:acadobs/features/marks/presentation/screens/marks_detail_screen.dart';
import 'package:acadobs/features/news/data/models/news_model.dart';
import 'package:acadobs/features/news/presentation/screens/news_full_screen.dart';
import 'package:acadobs/features/news/presentation/screens/news_screen_details.dart';
import 'package:acadobs/features/notices/data/models/notice_model.dart';
import 'package:acadobs/features/notices/presentation/screens/notice_details_screen.dart';
import 'package:acadobs/features/notices/presentation/screens/notice_listing_screen.dart';
import 'package:acadobs/features/parents/data/models/payment_model.dart';
import 'package:acadobs/features/parents/presentation/screens/payment_detail_screen.dart';
import 'package:acadobs/features/students/data/models/student_profile_args.dart';
import 'package:acadobs/features/students/data/models/student_screen_args.dart';
import 'package:acadobs/features/students/presentation/screens/student_achievement_screen.dart';
import 'package:acadobs/features/students/presentation/screens/student_detail_screen.dart';
import 'package:acadobs/features/students/presentation/screens/student_exam_screen.dart';
import 'package:acadobs/features/students/presentation/screens/student_homework_screen.dart';
import 'package:acadobs/features/students/presentation/screens/student_leave_screen.dart';
import 'package:acadobs/features/students/presentation/screens/student_notice_screen.dart';
import 'package:acadobs/features/students/presentation/screens/student_profile_screen.dart';
import 'package:acadobs/features/students/presentation/screens/students_listing_screen.dart';
import 'package:acadobs/features/students/presentation/widgets/time_table_day_tab.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_model.dart';
import 'package:acadobs/features/teacher/data/models/attendance/attendance_upload_model.dart';
import 'package:acadobs/features/teacher/data/models/leave_model.dart';
import 'package:acadobs/features/teacher/data/models/note_model.dart';
import 'package:acadobs/features/teacher/data/models/staff_duty_model.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/attendance_details_screen.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/attendance_taking_screen.dart';
import 'package:acadobs/features/teacher/presentation/attendance/screens/edit_attendance_screen.dart';
import 'package:acadobs/features/teacher/presentation/duties/screens/duty_detail_screen.dart';
import 'package:acadobs/features/teacher/presentation/home/screens/edit_profile_staff.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/screens/leave_request_detail_screen.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/screens/student_leaves_screen.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/screens/teacher_leave_request_home_screen.dart';
import 'package:acadobs/features/teacher/presentation/notes/screens/note_details_screen.dart';
import 'package:acadobs/features/teacher/presentation/notes/screens/note_listing_screen.dart';
import 'package:acadobs/features/timetable/presentation/time_table_day_tab_staff.dart';
import 'package:acadobs/routes/router_constants.dart';
import 'package:acadobs/shared/models/detail_screen_args.dart';
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
        forStaff: studentDetailParams.forStaff,
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
      final NoticeModel noticedetail = state.extra as NoticeModel;
      return NoticeDetailsScreen(notices: noticedetail);
    },
  ),

  //noticedetails
  GoRoute(
    path: '/noticeListscreen',
    name: RouteConstants.noticeListscreen,
    builder: (context, state) {
      // final Notices noticedetail = state.extra as Notices;
      return NoticeListingScreen();
    },
  ),

  //events
  GoRoute(
    path: '/eventdetails',
    name: RouteConstants.eventlistdetails,
    builder: (context, state) {
      final EventModel eventdetail = state.extra as EventModel;
      return EventDetailScreen(events: eventdetail);
    },
  ),

  GoRoute(
    path: '/eventListscreen',
    name: RouteConstants.eventListscreen,
    builder: (context, state) {
      final forStaff = state.extra as bool;
      return EventListingScreen(forStaff: forStaff);
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
      return NewsListingScreen(forStaff: forStaff);
    },
  ),

  GoRoute(
    path: '/newsScreen',
    name: RouteConstants.newsScreen,
    builder: (context, state) {
      final News news = state.extra as News;
      return NewsScreenDetails(news: news);
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
    path: '/achievementList',
    name: RouteConstants.achievementList,
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
      final args = state.extra as DetailScreenArgs;
      return AchievementDetailsScreen(
        achievementId: args.id,
        forStaff: args.forStaff,
      );
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

  GoRoute(
    path: '/timetabledaytabStaff',
    name: RouteConstants.timeTableDayTabStaff,
    builder: (context, state) {
      final forStaff = state.extra as bool;
      return TimeTableDayTabStaff(forStaff: forStaff);
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

  //edit profile for staff
  GoRoute(
    path: '/editProfileStaff',
    name: RouteConstants.editProfileStaff,
    builder: (context, state) {
      return EditProfileStaff();
    },
  ),

  //school achievement for staff
  GoRoute(
    path: '/schoolAchievements',
    name: RouteConstants.schoolAchievements,
    builder: (context, state) {
      final forStaff = state.extra as bool;
      return SchoolAchievementListing(forStaff: forStaff);
    },
  ),
  GoRoute(
    path: '/studentHomeworkScreen',
    name: RouteConstants.studentHomeworkScreen,
    builder: (context, state) {
      final args = state.extra as StudentScreenArgs;
      return StudentHomeworkScreen(
        studentId: args.studentId,
        forStaff: args.forStaff,
      );
    },
  ),
  //student exam screen
  GoRoute(
    path: '/studentExamScreen',
    name: RouteConstants.studentExamScreen,
    builder: (context, state) {
      final args = state.extra as StudentScreenArgs;
      return StudentExamScreen(
        studentId: args.studentId,
        forStaff: args.forStaff,
      );
    },
  ),
  //student achievement screen
  GoRoute(
    path: '/studentAchievementScreen',
    name: RouteConstants.studentAchievementScreen,
    builder: (context, state) {
      final args = state.extra as StudentScreenArgs;
      return StudentAchievementScreen(
        studentId: args.studentId,
        forStaff: args.forStaff,
      );
    },
  ),

  //student notice screen
  GoRoute(
    path: '/studentNoticeScreen',
    name: RouteConstants.studentNoticeScreen,
    builder: (context, state) {
      final args = state.extra as StudentScreenArgs;
      return StudentNoticeScreen(
        studentId: args.studentId,
        forStaff: args.forStaff,
      );
    },
  ),
  GoRoute(
    path: '/studentLeaveScreen',
    name: RouteConstants.studentLeaveScreen,
    builder: (context, state) {
      final args = state.extra as StudentScreenArgs;
      return StudentLeaveScreen(
        studentId: args.studentId,
        forStaff: args.forStaff,
      );
    },
  ),
  //student profile screen
  GoRoute(
    path: '/studentProfileScreen',
    name: RouteConstants.studentProfileScreen,
    builder: (context, state) {
      final args = state.extra as StudentProfileArgs;
      return StudentProfileScreen(
        student: args.student,
        forStaff: args.forStaff,
      );
    },
  ),
];

class StudentDetailParameters {
  final int studentId;
  final bool forStaff;
  StudentDetailParameters({required this.forStaff, required this.studentId});
}
