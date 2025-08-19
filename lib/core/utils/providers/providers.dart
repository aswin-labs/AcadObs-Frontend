import 'package:acadobs/features/parents/presentation/provider/leave_request_student_provider.dart';
import 'package:acadobs/features/achievements/provider/acheivement_provider.dart';
import 'package:acadobs/features/events/presentation/provider/event_provider.dart';
import 'package:acadobs/features/notices/provider/notice_provider.dart';
import 'package:acadobs/features/superadmin/presentation/school_classes/provider/school_classes_provider.dart';
import 'package:acadobs/features/superadmin/presentation/school_subjects/provider/school_subjects_provider.dart';
import 'package:acadobs/features/superadmin/presentation/schools/provider/school_provider.dart';
import 'package:acadobs/features/teacher/presentation/attendance/provider/attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/duties/provider/duty_provider.dart';
import 'package:acadobs/features/homework/presentation/provider/homework_provider.dart';
import 'package:acadobs/features/news/presentation/provider/news_provider.dart';
import 'package:acadobs/features/teacher/presentation/leave_request/provider/teacher_leave_request_provider.dart';
import 'package:acadobs/features/marks/presentation/provider/marks_provider.dart';
import 'package:acadobs/features/students/presentation/provider/student_provider.dart';
import 'package:acadobs/shared/providers/subject_provider.dart';
import 'package:acadobs/shared/bottom_nav/controller/bottom_navbar_controller.dart';
import 'package:acadobs/shared/providers/dropdown_provider.dart';
import 'package:acadobs/shared/providers/file_picker_provider.dart';
import 'package:acadobs/shared/providers/shared_provider.dart';
import 'package:provider/provider.dart';

getProviders() {
  return [
    //**********COMMON PROVIDERS************//
    ChangeNotifierProvider(create: (_) => BottomNavbarController()),
    ChangeNotifierProvider(create: (_) => FilePickerProvider()),
    ChangeNotifierProvider(create: (_) => DropdownProvider()),
    ChangeNotifierProvider(create: (_) => SharedProvider()),

    //*************SUPER ADMIN*************//
    ChangeNotifierProvider(create: (_) => SchoolProvider()),
    ChangeNotifierProvider(create: (_) => SchoolClassProvider()),
    ChangeNotifierProvider(create: (_) => SchoolSubjectsProvider()),

    // **************STAFF****************//
    ChangeNotifierProvider(create: (_) => DutyProvider()),
    ChangeNotifierProvider(create: (_) => AttendanceProvider()),
    ChangeNotifierProvider(create: (_) => SubjectProvider()),
    ChangeNotifierProvider(create: (_) => StudentProvider()),
    ChangeNotifierProvider(create: (_) => TeacherLeaveRequestProvider()),
    ChangeNotifierProvider(create: (_) => HomeworkProvider()),
    ChangeNotifierProvider(create: (_) => SubjectProvider()),
    ChangeNotifierProvider(create: (_) => TeacherLeaveRequestProvider()),
    ChangeNotifierProvider(create: (_) => MarksProvider()),

    //**************NOTICES****************//
    ChangeNotifierProvider(create: (_) => NoticeProvider()),

    //**************EVENTS****************//
    ChangeNotifierProvider(create: (_) => EventProvider()),

    //**************EVENTS****************//
    ChangeNotifierProvider(create: (_) => StudentLeaveRequestProvider()),

    //**************EVENTS****************//
    ChangeNotifierProvider(create: (_) => NewsProvider()),

    //**************EVENTS****************//
    ChangeNotifierProvider(create: (_) => AchievementProvider()),
  ];
}
