import 'package:acadobs/features/superadmin/presentation/school_classes/provider/school_classes_provider.dart';
import 'package:acadobs/features/superadmin/presentation/school_subjects/provider/school_subjects_provider.dart';
import 'package:acadobs/features/superadmin/presentation/schools/provider/school_provider.dart';
import 'package:acadobs/features/teacher/presentation/attendance/provider/attendance_provider.dart';
import 'package:acadobs/features/teacher/presentation/duties/provider/duty_provider.dart';
import 'package:acadobs/features/teacher/presentation/subjects/provider/subject_provider.dart';
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
  ];
}
